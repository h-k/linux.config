#!/bin/bash
set -e

SRC=~/gitsvn

svnrebase()
{
	cd $1
	echo "$1: rebase .."
	git svn rebase
	echo "$1: rebase done"
	cd -
}

git_reset()
{
	cd $1
	echo "$1: reset .."
	git reset --hard
	echo "$1: reset done"
	cd -
}

do_2400()
{
	cd $SRC/$1
	echo "REPO $1: START SVN $2.."
	git svn rebase
	$2 utils/clusterd
	$2 utils/mapd

	cd kernel

	$2 ce_atm
	$2 ce_atm_classifier
	$2 ce_lite_atm
	$2 ce_cluster
	$2 ce_map

	cd cl_drv

	$2 ce_wrs
	$2 celeno_cb
	repos+="${1}\n"
	echo "REPO $1: DONE SVN $2"
}

do_2400_all()
{
	do_2400 4.7.x $1
}

do_2330()
{
	cd $SRC/$1

	echo "REPO $1: START SVN $2..."
	git svn rebase
	svnrebase ce_atm
	svnrebase ce_atm_classifier
	svnrebase ceclass
	svnrebase clusterd

	cd wlan-v7/driver/linux

	svnrebase celeno_cb
	svnrebase ce_cluster
	svnrebase ce_wrs
	repos+="${1}\n"
	echo "REPO $1: DONE SVN $2"
}

do_2330_all()
{
	do_2330 5.2.x_mercury_27/CL2330 $1
}

do_242()
{
	cd $SRC/$1

	echo "REPO $1: START SVN $2.."
	$2 .
	cd linux-2.6.21.x/drivers/net
	$2 celeno_cb
	$2 ce_cluster
	$2 ceclass

	cd wireless
	$2 ce_atm
	$2 ce_atm_classifier

	cd CL242
	$2 ce_wrs
	repos+="${1}\n"

	echo "REPO $1: DONE SVN $2"
}

do_242_all()
{
	do_242 6.70.0xx_mercury_27 $1
}

do_bahamas()
{
	cd $SRC/$1

	echo "REPO $1: START SVN $2.."
	$2 .
	cd user/celeno
	$2 clusterd
	cd $SRC/$1

	cd linux-2.6.36.x/drivers/net
	$2 celeno_cb
	$2 ce_cluster
	$2 ceclass

	cd wireless
	$2 ce_atm
	$2 ce_atm_classifier
	$2 ce_wrs
	repos+="${1}\n"

	echo "REPO $1: DONE SVN $2"
}

do_deskap()
{
	echo "do_deskap: $1 $2"
	cd $SRC/$1

	echo "REPO $1: START SVN $2.."

	$2 .

	cd CL2330
	$2 cfg
	$2 scripts
	cd $SRC/$1

	cd CL242
	$2 cfg
	$2 scripts
	cd $SRC/$1

	cd linux-2.6.36.x/drivers/net
	$2 celeno_cb
	$2 ce_cluster
	$2 ceclass

	cd wireless
	$2 ce_atm
	$2 ce_atm_classifier
	$2 CL2330
	cd driver/linux
	$2 celeno_cb
	$2 ce_cluster
	$2 ce_wrs

	$2 CL242

	cd CL2200
	$2 ce_wrs
	cd ..

	cd CLR260
	$2 ce_wrs
	cd ..

	cd $SRC/$1
	cd user
	$2 hostapd-2.1
	cd $SRC/$1

	repos+="${1}\n"

	echo "REPO $1: DONE SVN $2"
}

do_bahamas_all()
{
	do_bahamas 6.87.0xx_cmv2 $1
}


do_deskap()
{
	do_deskap $1 $2
}

do_deskap_all()
{
	do_deskap 6.84.0xx_DeskAP_27 $1
}

update_all()
{
	do_2330_all svnrebase
	do_2400_all svnrebase
	do_242_all svnrebase
	do_bahamas_all svnrebase
	do_deskap_all svnrebase
}

do_platform()
{
	case $1 in
	cl2330)
		do_2330_all $2
		;;

	cl2400)
		do_2400_all $2
		;;

	cl242)
		do_242_all $2
		;;

	bahamas)
		do_bahamas_all $2
		;;

	deskap)
		do_deskap_all $2
		;;

	*)	;;
	esac
}

usage()
{
	echo "Usage:"
	echo "rebase.sh"
	echo "rebase.sh cl2330"
	echo "rebase.sh cl242"
	echo "rebase.sh bahamas"
	echo "rebase.sh deskap"
	echo "rebase.sh cl2400"
}

proc_short()
{
	case $1 in
	cl2330)
		do_2330_all svnrebase
		;;

	cl2400)
		do_2400_all svnrebase
		;;

	cl242)
		do_242_all svnrebase
		;;

	bahamas)
		do_bahamas_all svnrebase
		;;

	deskap)
		do_deskap_all svnrebase
		;;

	reset_deskap)
		reset_deskap 6.84.0xx_DeskAP_27
		;;

	reset)
		do_platform $2 git_reset
		;;

	rebase)
		do_platform $2 svnrebase
		;;

	?)
		usage
		;;

	*)	;;
	esac
}

main() {
	SECONDS=0
	numargs=$#
	declare -a repos

	SRC=~/gitsvn
	if [[ $numargs == 1 ]] ; then
		proc_short $1
	elif [[ $numargs == 2 ]] ; then
		proc_short $1 $2
	else
		update_all
	fi
	echo "SVN REBASE DONE. This took $SECONDS seconds."
	echo "REBASED :"
	echo -e ${repos[@]}
}

main $@



