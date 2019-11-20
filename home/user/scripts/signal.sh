#!/bin/sh
set -e

count=10
pauze=1
SIGNAL=SIGUSR1

_signal()
{
	echo "#$count: send signal $SIGNAL to $pid"
	cmcli get ap_db
	kill -SIGUSR1 $pid
	cmcli get ap_db
}

main()
{
	numargs=$#
	pid=`cat /tmp/clusterd.pid`
	echo "numargs=$numargs"
	if [[ $numargs == 4 ]] ; then
		SIGNAL=$1
		count=$2
		pauze=$3
		pid=$4
	else
		echo "usage:"
		echo "signal.sh [SIGNAL] [count] [pauze] [pid]"
		echo "default: signal.sh SIGUSR1 10 5 'cat /tmp/clusterd.pid'"
	fi

	while [ $count -ge 0 ]
	do
		_signal
		sleep $pauze
		count=$((count - 1))
	done
}

main $@
