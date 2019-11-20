#!/bin/bash
set -x
set -e

SECONDS=0

PLATFORM=ARRIS_P7
PACKAGE=cl2400

BRANCH=`basename $(pwd)`

echo "BRANCH=$BRANCH"

rm -rf celeno_clr_package_*/  SOURCE_CODE_*.tar.bz || true
./make_CL2400_release.sh -p ${PLATFORM}

tar xf SOURCE_CODE_celeno_clr_package_cl2400_*
cd celeno_clr_package_cl2400_ARRIS_P7/

export PATH=/export/dev-root/34xx_7.1.1/build-arrisatom/tmp/sysroots/x86_64-linux/usr/bin/core2-32-rdk-linux/:$PATH
sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = /home/alexander/ccache/34xx_7.1.1/i586-rdk-linux-#' src/celeno.mk
sed -i -e 's#^\s*DEF_CONF_LINUX_SRC\s*=.*$#DEF_CONF_LINUX_SRC = $(DEF_SDK_PATH)/../linux-arrisatom-sdk7.2.1er4#' src/celeno.mk
export CCACHE_PATH=/export/dev-root/34xx_7.1.1/build-arrisatom/tmp/sysroots/x86_64-linux/usr/bin/core2-32-rdk-linux/:$PATH

make

tar -czf cl2400.tar build

cp cl2400.tar /tftpboot/

notify-send -i starred "host package $PACKAGE $BRANCH $PLATFORM" "build done in $SECONDS seconds"
