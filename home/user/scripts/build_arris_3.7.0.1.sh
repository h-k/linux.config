#!/bin/bash
set -x
set -e

CURR_DIR=$(pwd)

cd "$CURR_DIR"

rm -rf celeno_clr_package_*/  SOURCE_CODE_*.tar.bz || true
./make_CL2400_release.sh -p ARRIS_P7

tar xf SOURCE_CODE_celeno_clr_package_cl2400_*
cd celeno_clr_package_cl2400_ARRIS_P7/

export PATH=/export/dev-root/34xx_7.0.1/build-arrisatom/tmp/sysroots/x86_64-linux/usr/bin/core2-32-rdk-linux/:$PATH
sed -i -e 's#^\s*DEF_SDK_PATH.*$#DEF_SDK_PATH = /export/dev-root/34xx_7.0.1#' src/celeno.mk
sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = /home/alexander/ccache/34xx_7.0.1/i586-rdk-linux-#' src/celeno.mk
export CCACHE_PATH=$SDK/build-arrisatom/tmp/sysroots/x86_64-linux/usr/bin/core2-32-rdk-linux/:$PATH

make

tar -czf cl2400.tar build

cp cl2400.tar /tftpboot/
