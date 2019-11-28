#!/bin/bash
set -x
set -e

SECONDS=0

PLATFORM=CBN_INTELP6_YOCTO
PACKAGE=cl242

SDKDIR=~/gitsvn/SDK
SDK=/opt/intel/puma6-r6.1.5-ga/puma6-build-thirdpartywifi/thirdpartywifi_r6.1.5-ga
SRCDIR=`pwd`

BRANCH=`basename $(pwd)`
export CLR=$SRCDIR
export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM

echo "SRCDIR=$SRCDIR"
echo "CLR=$CLR"
echo "HP_LOCATION=$HP_LOCATION"

rm -rf clr_package_release/$PACKAGE || true
make $PACKAGE platform=$PLATFORM

cd $HP_LOCATION
tar xf SOURCE_CODE_celeno_clr_package_*_cl242_*.tar.bz2
cd celeno_clr_package*_cl242_**

export PATH=${SDK}/build-intelce/tmp/sysroots/x86_64-linux/usr/bin/core2-32-poky-linux/:$PATH
sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = $(HOME)/ccache/yocto_6.1.5_ccache/i586-poky-linux-#' src/celeno.mk
export CCACHE_PATH=${SDK}/build-intelce/tmp/sysroots/x86_64-linux/usr/bin/core2-32-poky-linux/:$PATH

make

mv build/${PLATFORM} cl242
tar -czf cl242.tar cl242
cp cl242.tar /tftpboot/

cd $SRCDIR

notify-send -i starred "host package $PACKAGE $SRCDIR $PLATFORM" "build done in $SECONDS seconds"
