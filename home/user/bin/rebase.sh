#!/bin/bash
set -e

SRC=~/gitsvn

svnrebase()
{
	cd $1
	git svn rebase
	echo "$1: rebase done.."
	cd -
}

update_2400()
{
	cd $SRC/$1
	echo "REPO $1: START SVN rebase.."
	git svn rebase
	svnrebase utils/clusterd

	cd kernel

	svnrebase ce_atm
	svnrebase ce_atm_classifier
	svnrebase ceclass

	cd bp/net/mac80211

	svnrebase ce_wrs
	svnrebase celeno_cb
	svnrebase ce_cluster
	repos+="${1}\n"
	echo "REPO $1: DONE SVN rebase"
}

update_2400_all()
{
	update_2400 4.6.x_91_GA
	update_2400 4.6.x_92_GA4
	update_2400 4.7.x
}

update_2330()
{
	cd $SRC/$1

	echo "REPO $1: START SVN rebase.."
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
	echo "REPO $1: DONE SVN rebase"
}

update_2330_all()
{
	update_2330 5.2.x_mercury_25_new/CL2330
	update_2330 5.2.x_mercury_25_new_18_GA5/CL2330
}

update_242()
{
	cd $SRC/$1

	echo "REPO $1: START SVN rebase.."
	git svn rebase
	cd linux-2.6.21.x/drivers/net
	svnrebase celeno_cb
	svnrebase ce_cluster
	svnrebase ceclass

	cd wireless
	svnrebase ce_atm
	svnrebase ce_atm_classifier

	cd CL242
	svnrebase ce_wrs
	repos+="${1}\n"

	echo "REPO $1: DONE SVN rebase"
}

update_242_all()
{
	update_242 6.70.0xx_mercury_25_new
	update_242 6.70.0xx_mercury_25_new_18_GA5
}

update_bahamas()
{
	cd $SRC/$1

	echo "REPO $1: START SVN rebase.."
	git svn rebase
	cd user/celeno
	svnrebase clusterd
	cd $SRC/$1

	cd linux-2.6.36.x/drivers/net
	svnrebase celeno_cb
	svnrebase ce_cluster
	svnrebase ceclass

	cd wireless
	svnrebase ce_atm
	svnrebase ce_atm_classifier
	svnrebase ce_wrs
	repos+="${1}\n"

	echo "REPO $1: DONE SVN rebase"
}

update_bahamas_all()
{
	update_bahamas 6.87.0xx
	update_bahamas 6.87.0xx_3_GA5
	update_bahamas 6.85.0xx_comtrend_CM
}

update_all()
{
	update_2330_all
	update_2400_all
	update_242_all
	update_bahamas_all
}

usage()
{
	echo "Usage:"
	echo "rebase.sh"
	echo "rebase.sh cl2330"
	echo "rebase.sh cl242"
	echo "rebase.sh bahamas"
	echo "rebase.sh cl2400"
}

proc_short()
{
	case $1 in
	cl2330)
		update_2330_all
		;;

	cl2400)
		update_2400_all
		;;

	cl242)
		update_242_all
		;;

	bahamas)
		update_bahamas_all
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
	else
		update_all
	fi
	echo "SVN REBASE DONE. This took $SECONDS seconds."
	echo "REBASED :"
	echo -e ${repos[@]}
}

main $@



