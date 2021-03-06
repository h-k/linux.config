#!/bin/sh
set -e

nofify_level="WARN"
pauze=1
NAME=/tmp/notify.txt
NAME_TMP=/tmp/notify_tmp.txt

usage()
{
	echo "usage:"
	echo "notifyd.sh [pauze]"
	echo "default: notifyd.sh 1"
}

# param 1 - string
log()
{
	echo $1
	if [ "nofify_level" = "ALL" ]; then
		notify-send -u critical -i starred $1
	fi
}

# param 1 - branch
# param 2 - sdk version
build_branch_sdk()
{
	local branch=$1
	local sdk=$2

	case $branch in
	4.7.x_23_GA15)
		case $sdk in
		yocto_3.7.1.1)
			log "run ~/repo/4.7.x_23_GA15/build_arris_3.7.1.1.sh"
			cd ~/repo/4.7.x_23_GA15/

			log "<<<<<<<<<<<<<<<<<<<<<< 4.7.x_23_GA15 SDK yocto_3.7.1.1 >>>>>>>>>>>>>>>>>>>>>"

			~/repo/4.7.x_23_GA15/build_arris_3.7.1.1.sh
			cd - > /dev/null
			;;

		*)	echo "Bad SDK version name $sdk"
			;;
		esac
		;;

	*)	echo "Bad branch name $branch"
		;;
	esac
}

main()
{
	numargs=$#

	if [ $numargs = "1" ] ; then
		if [ "$1" = "-h" ] ; then
			usage
			exit
		fi
		pauze=$1
	fi

	touch $NAME_TMP
	while true
	do
		sleep $pauze
		echo "NAME=$NAME"
		if [ -f $NAME ] ; then
			echo "ddd=$dd2"
			dd2=`diff -q ${NAME} ${NAME_TMP}`
			echo "2 ddd=$dd2"
			if [ -n "$ddd" ] ; then
				local str=`cat $NAME`
				log "$str"

				# add line ex. `START DRIVER BUILD#4.7.x_23_GA15=yocto_3.7.1.1` for auto-start compilation
				local build=`grep "START DRIVER BUILD" $NAME`
				local must_build=
				if [ "$build" = "" ] ; then
					must_build=0
				else
					must_build=1
				fi

				echo "must_build=$must_build"
				if [ "$must_build" != "1" ] ; then
					echo "$str"
					notify-send -u critical -i starred "$str"
					cp $NAME $NAME_TMP
					continue
				fi

				if [ "$must_build" = "1" ] ; then
					local str1=${str#*#}
					branch=$(echo $str1 | cut -f1 -d=)
					sdk=$(echo $str1 | cut -f2 -d=)
				fi


				build_branch_sdk $branch $sdk
			fi

			cp $NAME $NAME_TMP
		else
			echo "NAME=$NAME not -f ??"
		fi

	done
}

main $@
