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
		if [ -f $NAME ] ; then
			local _dd=`diff -q $NAME $NAME_TMP`
			if [ -n "$_dd" ] ; then
				local str=`cat $NAME`
				notify-send -i starred "$str"
			fi

			cp $NAME $NAME_TMP
		fi

		sleep $pauze
	done
}

main $@
