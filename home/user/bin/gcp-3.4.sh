#!/bin/bash

# 1 - server
# 2 - patch list file
# 3 - branch
# 4 - src_dir
# 5 - bld_dir
# 6 - remote

REPO="alexander@review.omapzoom.org"
CACHE_DIR="patches/gerrit/cache"
PWD=`pwd`
GERRIT="ssh://$REPO:29418/repo/omapboot"
BRANCH="p-master-dev"
REMOTE="remotes/origin"
SOURCES="/home/x0187394/work/omapboot/omapboot"
OUT=$SOURCES
PLIST="list_omapboot_omap4.txt"
PLIST_PROX="mega_prox.prox"
NOFETCH="0"
CONFIG="android_omap_defconfig"
PTNAME="patch.am"
CR_CM=$CROSS_COMPILE
RAMDISK=""
DISTCCHOST="111"
DISTCCAVAIL="0"
MAKE="make"
JOBS=9
CR_COMPILE=
PATCHES=""

distcc_check() {
 if [[ ! -z $DISTCCHOST ]]; then
 	ping -W1 -c1 $DISTCCHOST 2>&1 > /dev/null
 	if [[ "$?" == "0" ]]; then
		echo ">>>> Companion host available"
		export DISTCC_HOSTS="$DISTCCHOST,cpp,lzo/1"
		MAKE="pump make"
		JOBS=20
		CR_COMPILE="distcc $CR_CM"
	else
		CR_COMPILE="$CR_CM"
		echo ">>> Companion host UNavailable"
	fi
 fi
}

update_config() {
	echo "CONFIG_BLK_DEV_INITRD=y" >> .config
	echo "CONFIG_INITRAMFS_SOURCE=\"$1\"" >> .config
	echo "CONFIG_INITRAMFS_ROOT_UID=0" >> .config
	echo "CONFIG_INITRAMFS_ROOT_GID=0" >> .config
	echo "CONFIG_RD_GZIP=y" >> .config
	echo "CONFIG_INITRAMFS_COMPRESSION_GZIP=y" >> .config
}

make_boot_img() {
	echo -n ">>> Make a boot_image"
	cd $OUT/arch/arm/boot

	if [ ! -f ramdisk.img ]; then
   		touch ramdisk.img
	fi

	if [ -f boot.img.old ];then
		mv boot.img.old boot.img.old.old
	fi

	if [ -f boot.img ]; then
		mv boot.img boot.img.old
	fi

	mkbootimg --kernel zImage --ramdisk ramdisk.img --base 0x80000000 --cmdline "" --board omap4 -o boot.img

	echo "  [DONE]"
}

error() {
echo "[E]: "$1
}

get_changeid() {
  case $1 in
  */*) echo ${1%%/*} ;;
  *)   echo $1 ;;
  esac
}

get_last_patchset() {
 id=`ssh $REPO gerrit query --current-patch-set $1 | grep -A 2 currentPatchSet | grep number | cut -f2 -d:`
 echo $id
}

make_patch() {
	git fetch $1 $2 && git format-patch -1 --stdout FETCH_HEAD > $3
}

apply_patch() {
	git am $1
}

parse_patch_list() {
	
	if [[ ! -z $PLIST_PROX ]]; then
		if [[ ! -f $SOURCES/$PLIST_PROX ]]; then
			echo ">>> No PatchList file."
			return
		fi
		while read -r ID; do
			REM=`echo $ID | grep '#'`
			if [[ ! -z $REM ]]; then 
				continue
			fi
		PLIST_SET="$PLIST_SET $ID"
		done < $SOURCES/$PLIST_PROX
	else
		if [[ ! -f $SOURCES/$PLIST ]]; then
			echo ">>> No PatchList file."
			return
		fi
		PLIST_SET=$PLIST
	fi
	
	echo ">>> Patch files: " $PLIST_SET
	for i in $PLIST_SET; do
		while read -r ID; do
			REM=`echo $ID | grep '#'`
			if [[ ! -z $REM ]]; then 
				continue
			fi
		PATCHES="$PATCHES $ID"
		done < $SOURCES/$i
	done
	
	echo ">>> Patches for apply: " $PATCHES
}

to_ref() {
  case $1 in
  */*)
    change_id=${1%%/*}
    patchset_id=${1##*/}
    ;;
  *)
    change_id=$1
    patchset_id=$(get_last_patchset $1)
    ;;
  esac

  hash=$(($change_id % 100))
  case $hash in
  [0-9]) hash="0$hash" ;;
  esac

  echo "refs/changes/$hash/$change_id/$patchset_id"
}

get_revid() {
  grep $(to_ref $1) <"$GIT_DIR/FETCH_HEAD" | cut -f1
}

fetch_remote() {
	if [[ "$NOFETCH" == "0" ]]; then
	#Fetching the repo
		cd $SOURCES
		echo -n ">>> Fetching remote: "$REMOTE
		if [[ -z $REMOTE ]]; then
			echo " .... [ERROR]"
			echo "Please set the remote name"
			exit 1
		fi
	
		OUTPUT=$(git fetch $REMOTE 2>&1)
		if [[ "$?" != "0" ]]; then
			echo " .... [ERROR]"
			echo "$OUTPUT"
			exit 1
		else
			echo " .... [DONE]"
		fi
	else
		echo ">>> Fetch:  NoFetch option."
	fi
}

cherry_pick() {
	for PS in $PATCHES; do
		REF=$(to_ref $PS)
		REV=${REF##*/}
		PPATH=$CACHE_DIR/$PS/$REV
		PNAME=$PPATH/$PTNAME
#	echo "PS=$PS REF=$REF REV=$REV PPATH=$PPATH PNAME=$PNAME"
		echo
		echo "============== $PS =================="
		echo
	 	if [[ ! -d $PPATH ]]; then
	 		mkdir -p $PPATH
	 	fi
	 	if [[ ! -f $PNAME ]]; then
#			echo "make patch GERRIT=$GERRIT REF=$REF PNAME=$PNAME"
	   		$(make_patch $GERRIT $REF $PNAME)
	 	fi
	
	 	git am --reject $PNAME
		if [[ "$?" == "0" ]]; then
			echo ">>>>>>> [DONE]"
		else
			echo ">>>>>>> [ERROR]"
			if [[ "$WALL" == "Y" ]]; then
				exit 1
			fi
			git am --skip
			return
		fi
	done
}

branch_checkout() {
	cd $SOURCES
	echo -n ">>> Branch checkout"
	if [[ -z $BRANCH ]]; then
		echo " .... [ERROR]"
		error "Please specify branch name"
	fi
	
	OUTPUT=$(git checkout $REMOTE/$BRANCH -b $BRANCH-custom-$(date '+%s') 2>&1)
	if [[ "$?" != "0" ]]; then
		echo " .... [ERROR]"
		echo "$OUTPUT"
		exit 1
	else
		echo " .... [DONE]"
	fi
}

build_sources() {
	cd $OUT
	make ARCH=arm clean
	make ARCH=arm $CONFIG
	distcc_check
	if [[ ! -z $RAMDISK ]]; then
		$(update_config $RAMDISK)
	fi
	
	export CROSS_COMPILE=$CR_COMPILE 
	time $MAKE ARCH=arm -j$JOBS
}

#Parse params
while getopts "G:L:R:B:S:O:C:Nc:" OPT
do
	case $OPT in
	G)
	  GERRIT=$OPTARG
	  ;;
	L)
	  PLIST=$OPTARG
	  ;;
	R)
	  REMOTE=$OPTARG
	  ;;
	B)
	  BRANCH=$OPTARG
	  ;;
	S)
	  SOURCES=$OPTARG
	  ;;
	O)
	  OUT=$OPTARG
	  ;;
	C)
	  CACHE_DIR=$OPTARG
	  ;;
	c)
	  CONFIG=$OPTARG
	  ;;
	N)
	  NOFETCH="1"
	  ;;
	esac
done

if [[ ! -d $SOURCES ]]; then
	echo "Sources directory is incorrect"
	exit 1
fi

if [[ ! -d $OUT ]]; then
	echo "Build directory is incorrect"
	exit 1
fi

#Create/check cache directory
if  [[ ! -d $CACHE_DIR ]]; then
	mkdir -p $CACHE_DIR
	echo "Cache directory created."
else
	echo ">>> Cache directory exist."
fi

#Check for patch list
if [[ ! -f $SOURCES/$PLIST ]]; then
	echo "Patch list file not exist ?"
	echo "$SOURCES/$PLIST"
	exit 1
fi

parse_patch_list
#fetch_remote
branch_checkout
cherry_pick
#build_sources
#make_boot_img

