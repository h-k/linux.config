#!/bin/sh
set -e

pauze=1
NAME=/tftpboot/notify.txt
NAME_TMP=/tmp/notify_tmp.txt

main()
{
	numargs=$#

	if [[ $numargs == 1 ]] ; then
		if [ "$1" = "-h" ] ; then
			echo "usage:"
			echo "notifyd.sh [pauze]"
			echo "default: notifyd.sh 1"
			exit
		fi
		pauze=$1
	fi

	touch $NAME_TMP
	while true
	do
		sleep $pauze
		if [ -f $NAME ] ; then
			local _dd=`diff -q $NAME $NAME_TMP`
			if [ -n "$_dd" ] ; then
				local str=`cat $NAME`
				notify-send -i starred "$str"

				local build=`grep "START DRIVER BUILD" $NAME`
				if [ "$build" = "" ] ; then
					echo "build not catched"
					cp $NAME $NAME_TMP

					continue
				fi

				local str1=${str#*#}
				branch=$(echo $str1 | cut -f1 -d=)
				sdk=$(echo $str1 | cut -f2 -d=)

				case $branch in
					4.7.x_23_GA15)
						echo "4.7.x_23_GA15 matched"
						case $sdk in
							yocto_3.7.1.1)
							notify-send -i starred "run ~/repo/4.7.x_23_GA15/build_arris_3.7.1.1.sh"
							cd ~/repo/4.7.x_23_GA15/
							~/repo/4.7.x_23_GA15/build_arris_3.7.1.1.sh
							cd -
							;;

							*)	echo "Bad SDK version name $sdk"
							;;
						esac

					;;

					*)	echo "Bad branch name $branch"
					;;
				esac

			fi

			cp $NAME $NAME_TMP
		fi

	done
}

main $@
