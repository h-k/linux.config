#!/bin/bash
set -x
set -e

SECONDS=0

PLATFORM=BRCM3390
PACKAGE=cl2400

BRANCH=`basename $(pwd)`

echo "BRANCH=$BRANCH"

rm -rf celeno_clr_package_*/  SOURCE_CODE_*.tar.bz || true
./make_CL2400_release.sh -p ${PLATFORM}

tar xf SOURCE_CODE_celeno_clr_package_cl2400_*
cd celeno_clr_package_cl2400_BRCM3390/

export PATH=/opt/toolchain/stbgcc-4.8-1.5/bin/:$PATH
sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = /home/alexander/ccache/brcm_3390/arm-linux-gnueabihf-#' src/celeno.mk
export CCACHE_PATH=/opt/toolchain/stbgcc-4.8-1.5/bin/:$PATH

make

tar -czf cl2400.tar build

cp cl2400.tar /tftpboot/

notify-send -i starred "host package $PACKAGE $BRANCH $PLATFORM" "build done in $SECONDS seconds"
