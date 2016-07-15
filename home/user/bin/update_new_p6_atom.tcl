#!/usr/bin/env tclsh
package require Expect
package require cmdline

set parameters {
	{atom.arg	"ttyUSB2"	"ATOM port"}
	{arm.arg	"ttyUSB3"	"ARM port"}
	{server.arg	"192.168.100.80"	"Server IP"}
	{filename.arg	"appcpuImage"	"Image filename"}
}

array set arg [cmdline::getoptions argv $parameters]

# set console devices

set port_ATOM $arg(atom)
set port_ARM $arg(arm)

# TFTP server address
set server_ip $arg(server)
# attach mode: raw / screen
# Screen example:
# screen -mS ttyUSB0 minicom -w -c on -C /tmp/minicom_ttyUSB0_$(date +%F).log ttyUSB0
set spawn_mode "raw"
# old / new
set p6_version "new"

set baud_rate 115200
set filename $arg(filename)

set KEY_Esc		"\033"
set KEY_Up		"\033\[A"
set KEY_Down	"\033\[B"
set KEY_Left	"\033\[D"
set KEY_Right	"\033\[C"

proc init_tty {baud_rate port} {
	stty ispeed $baud_rate ospeed $baud_rate raw -echo cs8 -parenb -cstopb onlcr < /dev/$port
	# Time to wait for physical UART adjustment
	sleep 1
}

proc send_atom {text} {
	global spw_id_ATOM
	global port_ATOM
	global spawn_mode
	global baud_rate
	set try 0
	#sleep 1
	while {$try < 3} {
		if { [ catch { send -i $spw_id_ATOM $text } e ] } {
			catch { close -i $spw_id_ATOM } e
			init_tty $baud_rate $port_ATOM
			if { $spawn_mode == "raw" } {
				spawn -open [open /dev/$port_ATOM w+]
				set spw_id_ATOM $spawn_id
			} elseif { $spawn_mode == "screen" } {
				spawn screen -x $port_ATOM
				set spw_id_ATOM $spawn_id
			} else {
				exit 1
			}
			incr try
		} else {
			return
		}
	}
}
proc send_arm {text} {
	global spw_id_ARM
	global port_ARM
	global spawn_mode
	global baud_rate
	set try 0
    #sleep 1
	while {$try < 3} {
		if { [ catch { send -i $spw_id_ARM $text } e ] } {
			catch { close -i $spw_id_ARM } e
			init_tty $baud_rate $port_ARM
			if { $spawn_mode == "raw" } {
				spawn -open [open /dev/$port_ARM w+]
				set spw_id_ARM $spawn_id
			} elseif { $spawn_mode == "screen" } {
				spawn screen -x $port_ARM
				set spw_id_ARM $spawn_id
			} else {
				exit 1
			}
			incr try
		} else {
			return
		}
	}
}

proc change_settings {GbE_GMUX_Mode Boot_Type} {
	global spw_id_ATOM
	global KEY_Esc
	global KEY_Up
	global KEY_Down
	global KEY_Left
	global KEY_Right
	global p6_version

	set is_GbE_GMUX_Mode 0
	set is_Boot_Type 0
	set try_count 0
	set RED_BG "\u001b\\\[0;41;37m"
	set RED_BG_RE "\u001b\\\[0;41;37m"

	if { $p6_version == "new" } {
		set menu_stopper_RE "\u001b\\\[12;34H" 
		set GbE_GMUX_Mode_RE "${RED_BG_RE}\u001b\\\[07;34H(L2SW Mode|Pad0 Only|Pad0 and Pad1-L2-Moca|Pad1 and Pad0-L2-Moca|MoCA and Pad0-L2-Pad1)"
		set Boot_Type_RE "${RED_BG_RE}\u001b\\\[09;34H(No DOCSIS Boot|Normal)" 
		set skip_other_RE "${RED_BG_RE}\u001b(\\\[0\[3-68\]|\\\[1\[0-4\]);34H|\u001b\\\[\[01\]\[0-9\];34H${RED_BG_RE}" 
	} elseif { $p6_version == "old" } {
		set menu_stopper_RE "\u001b\\\[13;34H"
		set GbE_GMUX_Mode_RE "${RED_BG_RE}\u001b\\\[08;34H(L2SW Mode|Pad0 Only|Pad0 and Pad1-L2-Moca|Pad1 and Pad0-L2-Moca|MoCA and Pad0-L2-Pad1)"
		set Boot_Type_RE "${RED_BG_RE}\u001b\\\[10;34H(No DOCSIS Boot|Normal)" 
		set skip_other_RE "${RED_BG_RE}\u001b(\\\[0\[3-79\]|\\\[1\[1-4\]);34H|\u001b\\\[\[01\]\[0-9\];34H${RED_BG_RE}" 
	}
	send_atom "settings\r"
	set timeout 3
	expect {
		-i $spw_id_ATOM
		{F1: Save & Exit Setup (or F3, shift-S)} { ; }
		timeout { return 1 }
	}
	# Jump to Advanced Features
	set try_count 0
	while {$try_count < 10} {
		send_atom $KEY_Down
		expect {
			-i $spw_id_ATOM
			$RED_BG {
				expect {
					-i $spw_id_ATOM
					"About CEFDK" { ; }
					"Standard Features" { ; }
					"Advanced Features" {
						send_atom "\r"
						set try_count 100
						break
					}
					timeout { return 1 }
				}
			}
			timeout { return 1 }
		}
		incr try_count
	}
	if { $try_count < 100} {
		return 1
	}
	# Scan screen and wait for last lines
	expect {
		-i $spw_id_ATOM
		{F1: Save & Exit Setup (or F3, shift-S)} { ; }
		timeout { return 1 }
	}
	set try_count 0
	while {$try_count < 1} {
		expect {
			-i $spw_id_ATOM
			$GbE_GMUX_Mode { set is_GbE_GMUX_Mode 1 }
			$Boot_Type { set is_Boot_Type 1 }
			-re $menu_stopper_RE { incr try_count }
			timeout { incr try_count }
		}
	}

	if {$is_GbE_GMUX_Mode == 1 && $is_Boot_Type == 1} {
		# All is set alredy
		send_atom $KEY_Esc
		expect {
			-i $spw_id_ATOM
			{F1: Save & Exit Setup (or F3, shift-S)} {
				send_atom $KEY_Esc
				return 0
			}
			timeout { return 1 }
		}
		return 1
	}
	set try_count 0
	while {$try_count < 10 && ($is_GbE_GMUX_Mode == 0 || $is_Boot_Type == 0)} {
		send_atom $KEY_Down
		set timeout 1
		expect {
			-i $spw_id_ATOM
			-re $GbE_GMUX_Mode_RE {
				set try_count2 0
				while {$is_GbE_GMUX_Mode == 0 && $try_count2 < 20} {
					send_atom $KEY_Right
					expect {
						-i $spw_id_ATOM
						$GbE_GMUX_Mode {
							set is_GbE_GMUX_Mode 1
							set try_count2 100
							break
						}
						"L2SW Mode" { ; }
						"Pad0 Only" { ; }
						"Pad0 and Pad1-L2-Moca" { ; }
						"Pad1 and Pad0-L2-Moca" { ; }
						"MoCA and Pad0-L2-Pad1" { ; }
						timeout { return 1 }
					}
					incr try_count2
				}
				if { $try_count2 < 100} {
					return 1
				}
			}
			-re $Boot_Type_RE {
				set try_count2 0
				while {$is_Boot_Type == 0 && $try_count2 < 10} {
					send_atom $KEY_Right
					expect {
						-i $spw_id_ATOM
						$Boot_Type {
							set is_Boot_Type 1
							set try_count2 100
							break
						}
						"No DOCSIS Boot" { ; }
						"Normal" { ; }
						timeout { return 1 }
					}
					incr try_count2
				}
				if { $try_count2 < 100} {
					return 1
				}
			}
			-re $skip_other_RE { ; }
			timeout { ; }
		}
		incr try_count
	}
	send_atom "S"
	expect -i $spw_id_ATOM "shell>"
	send_atom "reset\r"
	set timeout 60
	expect -i $spw_id_ATOM "Hit a key to start the shell..."
	send_atom "\r"
	return 0
}

init_tty $baud_rate $port_ATOM

if { $spawn_mode == "raw" } {
	spawn -open [open /dev/$port_ATOM w+]
	set spw_id_ATOM $spawn_id
} elseif { $spawn_mode == "screen" } {
	spawn screen -x $port_ATOM
	set spw_id_ATOM $spawn_id
} else {
	exit 1
}

set timeout 60

send_user "\n\nStarted\n\n"
expect -i $spw_id_ATOM "Hit a key to start the shell..." {
	send_user "\n\n!!!!!!!! UBoot mode detected\n\n"
	send_atom "\r"
	set timeout 10
	expect -i $spw_id_ATOM "shell>"
	
	if [ change_settings "Pad0 and Pad1-L2-Moca" "No DOCSIS Boot" ] { exit 1 }
	expect -i $spw_id_ATOM "shell>"
	send_user  "\u001b\[0m\u001b\[2J"
	send_user "\n\nChanged settings\n\n"
	set timeout 60

	send_atom "tftp get $server_ip 0x900000 $filename\r"
	expect -i $spw_id_ATOM "done!"
	expect -i $spw_id_ATOM "shell>"

	send_user "\n\nLoaded\n\n"

	send_atom "cache flush\r"
	expect -i $spw_id_ATOM "shell>"

	# Set the serial port baud_raterate

    init_tty $baud_rate $port_ARM

	if { $spawn_mode == "raw" } {
		spawn -open [open /dev/$port_ARM w+]
		set spw_id_ARM $spawn_id
	} elseif { $spawn_mode == "screen" } {
		spawn screen -x $port_ARM
		set spw_id_ARM $spawn_id
	} else {
		exit 1
	}

	send_atom "ord4 0xC80D0000 0x03000000\r"
	expect -i $spw_id_ATOM "shell>"
	expect -i $spw_id_ARM "Press SPACE to abort autoboot"
	send_arm " "
	send_user "\n\nARM commands\n\n"
	expect -i $spw_id_ARM "=>"
	send_arm "update -t atom 1\r"
	expect -i $spw_id_ARM "=>"
	send_arm "update -t atom 2\r"
	expect -i $spw_id_ARM "=>"

	if [ change_settings "L2SW Mode" "Normal" ] { exit 1 }
	expect -i $spw_id_ATOM "shell>"
	send_user  "\u001b\[0m\u001b\[2J"

	send_atom "reset\r"
	send_user "\n\nDone!\n\n"
}

