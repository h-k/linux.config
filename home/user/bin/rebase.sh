#!/bin/bash
set -e

SRC=~/gitsvn

# type cl242
#6.70.0xx_mercury_25_new/
#6.87.0xx/
# other
#CE_ATM_2.0.0/
#CE_ATM_2.0.0_comtrend_6.87.0xx/
#CE_ATM_2.0.0_mercury_23_freeze_CM/
#CE_ATM_2.0.0_mercury_25_new/
#CE_CLASS_1.0.0/
#CE_CLASS_1.0.0_comtrend_6.87.0xx/
#CE_CLASS_1.0.0_mercury_23_freeze/
#CE_CLASS_1.0.0_mercury_25_new/
#CE_CLUSTER/
#CE_WRS_1.0.0_comtrend_6.87.0xx/
#CE_WRS_1.0.0_mercury_23_freeze/
#CE_WRS_1.0.0_mercury_25_new/
#CE_WRS_1.1.0/
#cgiweb/

svnrebase()
{
	cd $1
	git svn rebase
	echo "$1: rebase done.."
	cd -
}

update_2400()
{
	cd $1
	echo "REPO $1: START SVN rebase.."
	svnrebase utils/clusterd

	cd kernel

	svnrebase ce_atm
	svnrebase ce_atm_classifier
	svnrebase ceclass

	cd bp/net/mac80211

	svnrebase ce_wrs
	svnrebase celeno_cb
	svnrebase ce_cluster
	echo "REPO $1: DONE SVN rebase"
}

update_2400_all()
{
	update_2400 $SRC/4.6.x
	update_2400 $SRC/4.6.x_91_GA
	update_2400 $SRC/4.7.x
}

update_2330()
{
	cd $1

	echo "REPO $1: START SVN rebase.."
	svnrebase ce_atm
	svnrebase ce_atm_classifier
	svnrebase ceclass
	svnrebase clusterd

	cd wlan-v7/driver/linux

	svnrebase celeno_cb
	svnrebase ce_cluster
	svnrebase ce_wrs
	echo "REPO $1: START SVN rebase.."
}

update_2330_all()
{
	update_2330 $SRC/5.2.x_mercury_23_freeze_CM/CL2330
	update_2330 $SRC/5.2.x_mercury_25_new/CL2330
}

update_242()
{
	cd $1

	echo "REPO $1: START SVN rebase.."
	cd linux-2.6.21.x/drivers/net
	svnrebase celeno_cb
	svnrebase ce_cluster
	svnrebase ceclass

	cd wireless
	svnrebase ce_atm
	svnrebase ce_atm_classifier

	cd CL242
	svnrebase ce_wrs

	echo "REPO $1: START SVN rebase.."
}

update_242_all()
{
	update_242 $SRC/6.70.0xx_mercury_25_new
}

update_bahamas()
{
	cd $1

	echo "REPO $1: START SVN rebase.."
	cd user/celeno
	svnrebase clusterd

	cd linux-2.6.36.x/drivers/net
	svnrebase celeno_cb
	svnrebase ce_cluster
	svnrebase ceclass

	cd wireless
	svnrebase ce_atm
	svnrebase ce_atm_classifier
	svnrebase ce_wrs

	echo "REPO $1: START SVN rebase.."
}

update_bahamas_all()
{
	update_bahamas $SRC/6.87.0xx
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
	ECONDS=0
	numargs=$#

	SRC=~/gitsvn
	if [[ $numargs == 1 ]] ; then
		proc_short $1
	else
		update_all
	fi
	echo "SVN REBASE DONE. This took $SECONDS seconds."
}

main $@



