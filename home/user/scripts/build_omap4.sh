#!/bin/sh

# NOTE: Kernel and AFS need to be built

# ---- VARIABLES ----

repo_path=/home/x0178546/work/repos

android_path=$repo_path/omapzoom/afs_omap4
kernel_path=$repo_path/omapzoom/kernel
ddk_path=$repo_path/ddk/new/ddk

ddk_install_path=/tmp/_ddk_omap4_
toolchain_path=$android_path/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin
cur_dir=$(pwd)

# ---- FUNCTIONS ----

# DDK for OMAP4 must contains link to "external/" directory in AFS
fix_external_eurasia_issue() {
	echo "---> Fixing eurasia/external issue..."

	if [ ! -d $android_path/external ]; then
		echo " *** Error: There is no path $android_path/external"
		exit 1
	fi
	if [ ! -d $ddk_path ]; then
		echo " *** Error: There is no path $ddk_path"
		exit 1
	fi

	unlink $ddk_path/eurasia/external 1>&2 2>/dev/null
	ln -s $android_path/external $ddk_path/eurasia/external
}

export_common_vars() {
	echo "---> Exporting common vars..."

	export PATH=$toolchain_path:$PATH
	export CROSS_COMPILE=arm-eabi-
	export ANDROID_ROOT=$android_path
	export KERNELDIR=$kernel_path
	export WORKSPACE=$ddk_path
	export DISCIMAGE=$ddk_install_path
	export TARGET_ROOT=${ANDROID_ROOT}/out/target

	rm -rf $DISCIMAGE
	mkdir -p $DISCIMAGE
}

check_toolchain() {
	echo "---> Check out exported toolchain..."

	if [ ! -d $toolchain_path ]; then
		echo "Error: toolchain path not found"
		exit 1
	fi

	which arm-eabi-gcc >/dev/null
	if [ $? -eq 1 ]; then
		echo "Error: arm-eabi-gcc not found"
		exit 1
	fi
}

# Check dependencies (paths, files, tools)
check_deps() {
	echo "---> Sanity check..."

	if [ ! -d $ANDROID_ROOT ]; then
		echo "ANDROID_ROOT dir does not exist"
		exit 1
	fi

	if [ ! -d $KERNELDIR ]; then
		echo "KERNELDIR dir does not exist"
		exit 1
	fi

	if [ ! -d $WORKSPACE ]; then
		echo "WORKSPACE dir does not exist"
		exit 1
	fi

	if [ ! -d $DISCIMAGE ]; then
		echo "DISCIMAGE dir does not exist"
		exit 1
	fi

	if [ ! -f ${ANDROID_ROOT}/build/envsetup.sh ]; then
		echo "Error: build/envsetup.sh does not exist"
		exit 1
	fi

	if [ ! -d $TARGET_ROOT ]; then
		echo "TARGET_ROOT dir does not exist"
		echo "Maybe it worth to build AFS first?"
		exit 1
	fi

	fakeroot -v >/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "\"fakeroot\" tool is not installed"
		exit 1
	fi
}

export_afs_vars() {
	echo "---> Exporting AFS vars..."

	cd $ANDROID_ROOT

	echo "  * ---> envsetup.sh"
	. build/envsetup.sh

	echo "  * ---> lunch: Blaze Tablet, user debug"
	lunch blaze_tablet-userdebug

	cd $cur_dir
}

final_check_install_dir() {
	if [ ! -d $DISCIMAGE ]; then
		echo "    !!! ---> Installation dir not found; try to create..."
		mkdir $DISCIMAGE
		if [ -d $DISCIMAGE ]; then
			echo "    !!! ---> OK"
		else
			echo "    !!! ---> Fail"
			exit 1
		fi
	fi
}

build_ddk() {
	echo "---> Building DDK..."

	cd $WORKSPACE

	echo "  * ---> Stage 1"
	./build_DDK.sh -g 544sc --build release clobber
	echo "  * ---> Stage 2"
	./build_DDK.sh -g 544sc --build release
	echo "  * ---> Stage 3"
	final_check_install_dir
	fakeroot ./build_DDK.sh -g 544sc --install release

	cd $cur_dir
}

check_output() {
	res=$(ls -1 $ddk_install_path/system/lib/modules/ | grep ko)
	if [ -z "$res" ]; then
		echo " *** Error: module has not built:"
		echo "     $ddk_install_path/system/lib/modules/ is empty"
		exit 1
	fi
}

# ---- ENTRY POINT ----

export_common_vars
check_toolchain
check_deps
fix_external_eurasia_issue
export_afs_vars
build_ddk
check_output
