#!/bin/bash
set -x
set -e

SECONDS=0

PLATFORM=CBN_P6_YOCTO
PACKAGE=cl2400

SDKDIR=~/gitsvn/SDK
SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga

BRANCH=`basename $(pwd)`

echo "BRANCH=$BRANCH"

rm -rf celeno_clr_package_*/  SOURCE_CODE_*.tar.bz || true
./make_CL2400_release.sh -p ${PLATFORM}

tar xf SOURCE_CODE_celeno_clr_package_cl2400_*
cd celeno_clr_package_cl2400*

sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = $(HOME)/work/yocto_p6_ccache/i586-poky-linux-#' src/celeno.mk
export CCACHE_PATH=${SDK}/build/tmp/sysroots/x86_64-linux/usr/bin/core2-32-poky-linux:$PATH

make

tar -czf cl2400.tar build

cp cl2400.tar /tftpboot/

notify-send -i starred "host package $PACKAGE $BRANCH $PLATFORM" "build done in $SECONDS seconds"
