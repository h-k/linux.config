#!/bin/bash
set -x
set -e

SECONDS=0

PLATFORM=HUMAX
PACKAGE=cl2400

BRANCH=`basename $(pwd)`

echo "BRANCH=$BRANCH"

rm -rf celeno_clr_package_*/  SOURCE_CODE_*.tar.bz || true
./make_CL2400_release.sh -p ${PLATFORM}

tar xf SOURCE_CODE_celeno_clr_package_cl2400_*
cd celeno_clr_package_cl2400_HUMAX/

#export PATH=/export/dev-root/huawei_sdk/opt/RTOS/207.3.0/arm32A9le_4.4_ek_micro/gnu/bin/:$PATH
#sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = /home/alexander/ccache/huawei/arm-linux-musleabi-#' src/celeno.mk
#export CCACHE_PATH=/export/dev-root/huawei_sdk/opt/RTOS/207.3.0/arm32A9le_4.4_ek_micro/gnu/bin:$PATH

make

tar -czf cl2400.tar build

cp cl2400.tar /tftpboot/

notify-send -i starred "host package $PACKAGE $BRANCH $PLATFORM" "build done in $SECONDS seconds"
