#!/bin/sh
set -e

count=10
pauze=60

main()
{
	numargs=$#

	if [[ $numargs == 2 ]] ; then
		count=$1
		pauze=$2
	elif [[ $numargs == 3 ]] ; then
		count=$1
		pauze=$2
		IP=$3
	else
		echo "usage:"
		echo "restart.sh [count] [pauze]"
		echo "default: restart.sh 10 60"
		exit
	fi

	local g_count=$count
	while [ $count -ge 0 ]
	do
		local num=`expr $g_count - $count + 1`
		echo "**********RESTART #$num/$g_count**********"
		ce_host.sh restart dual
		echo "**********CE_HOST RESTART $num/$g_count DONE. WAIT $pauze SECONDS FOR NEXT RESTART**********"
		echo "restart.sh: RESTART $num/$g_count DONE" > notify.txt
		tftp -pl notify.txt $IP
		rm -rf notify.txt
		sleep $pauze
		count=$((count - 1))
	done

	echo "restart.sh: RESTARTED $num SUCCESSFULLY. EXIT" > notify.txt
	tftp -pl notify.txt $IP
	rm -rf notify.txt
}

main $@
