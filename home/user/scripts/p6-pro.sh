#!/bin/bash
set -e

sdktype=
pkgonly=

cgiweb_pre() {
	if [ "$sdktype" = "YOCTO" ] ; then
		rm -rf $SDK/build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/www
		rm -rf $SDK/build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/custom_targetFS_gateway/www
	else
		cd $SDK
		rm -f cgiweb_host_pkg-*.*
		rm -rf ./package/cgiweb
		rm -rf ./project_build_i686/IntelCE/cgiweb*
		rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
		sudo rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked
	fi

	cd $CLR
	if [ "$sdktype" = "YOCTO" ] ; then
		./make_cgiweb_release.sh -p $PLATFORM
		tar xf SOURCE_CODE_celeno_package_cgiweb_$PLATFORM.tar.bz2
	else
		./make_cgiweb_release.sh -p PUMA6
		tar xf SOURCE_CODE_celeno_package_cgiweb_PUMA6.tar.bz2
	fi

	cd celeno_package_cgiweb_$PLATFORM

	if [ "$sdktype" = "YOCTO" ] ; then
		cp -Rf platformdb/__common__/Yocto/meta-celeno $SDK/yocto
	else
		make $PLATFORM
		tar xf cgiweb_pkg_$PLATFORM.*.*.*.tar.bz2 -C $SDK
		cd $SDK
		add_packages "package/cgiweb"
	fi
}

clr250_pre() {
	cd $SDK
	rm -f clr250_host_pkg-*.*
	rm -f clr_host_pkg-$platform.tar
	rm -rf ./package/clr250
	rm -rf ./project_build_i686/IntelCE/clr250*
	sudo rm -rf ./project_build_i686/IntelCE/root/etc/Wireless/CLR250
	rm -rf project_build_i686/IntelCE/netconf_wifi_ap-*/.built
	rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
	rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked

	cd $CLR
	rm -rf clr_package_release/$PACKAGE
	make $PACKAGE platform=$PLATFORM

	cd $HP_LOCATION
	tar xf SOURCE_CODE_celeno_clr_package_*_$PACKAGE"_"$PLATFORM.tar*
        cd celeno_clr_package_*_$PACKAGE"_"$PLATFORM/
	make
	tar xf build/$PLATFORM/$PACKAGE"_"host_pkg-$platform.tar -C $SDK
	tar xf build/$PLATFORM/wlan_api.tar -C $SDK

	cd $SDK
	add_packages "package/$PACKAGE"

	cd wlan_api* && sudo make
	cd $SDK
}


###############################################################################
# Cleaning and unpacking functions for CLR240 host package
clr240_pre() {
	cd $SDK
	rm -f clr240_host_pkg-*.*
	rm -f clr_host_pkg-$platform.tar
	rm -rf ./package/clr240
	rm -rf ./project_build_i686/IntelCE/clr240*
	sudo rm -rf ./project_build_i686/IntelCE/root/etc/Wireless/CLR240
	rm -rf project_build_i686/IntelCE/netconf_wifi_ap-*/.built
	rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
	rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked

	cd $CLR
	rm -rf clr_package_release/$PACKAGE
	make $PACKAGE platform=$PLATFORM

	cd $HP_LOCATION
	tar xf SOURCE_CODE_celeno_clr_package_*_$PACKAGE"_"$PLATFORM.tar*
        cd celeno_clr_package_*_$PACKAGE"_"$PLATFORM/
	make
	tar xf build/$PLATFORM/$PACKAGE"_"host_pkg-$platform.tar -C $SDK
	tar xf build/$PLATFORM/wlan_api.tar -C $SDK

	cd $SDK
	add_packages "package/$PACKAGE"

	cd wlan_api* && sudo make
	cd $SDK
}

###############################################################################
# Cleaning and unpacking functions for CLR240 host package
cl2400_pre() {
	if [ "$sdktype" = "YOCTO" ] ; then
		rm -rf ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/cl2400 || true
		rm -rf ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/cl2400 || true
	fi

	cd $CLR
	if [ -d "celeno_clr_package_$PACKAGE"_"$PLATFORM" ] ; then
		rm -rf celeno_clr_package_$PACKAGE"_"$PLATFORM/
	fi
	./make_CL2400_release.sh -p $PLATFORM

	tar xf SOURCE_CODE_celeno_clr_package_cl2400_4.*.*.tar.gz
	cd celeno_clr_package_cl2400*

	if [ "$sdktype" = "YOCTO" ] ; then
		sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = $(HOME)/work/yocto_p6_ccache/i586-poky-linux-#' src/celeno.mk
		export CCACHE_PATH=${SDK}/build/tmp/sysroots/x86_64-linux/usr/bin/core2-32-poky-linux:$PATH
	fi

	make

	if [ "$sdktype" = "YOCTO" ] ; then
		mkdir -p $SDK/build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/cl2400
		cp -fr ./build/* $SDK/build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/cl2400/
	fi
	cd $SDK
}

cl2400_b0_pre()
{
	cl2400_pre
}

cl2400_4.7.x_pre()
{
	cl2400_pre
}

###############################################################################
# Cleaning and unpacking functions for CLR242 host package
cl242_pre() {
	cd $SDK
	if [ "$sdktype" = "YOCTO" ] ; then
		rm -rf ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL || true
	else
		rm -f cl242_host_pkg-*.*
		rm -f clr_host_pkg-$platform.tar
		rm -f $PACKAGE-GA.tgz
		rm -rf ./package/cl242
		rm -rf ./project_build_i686/IntelCE/cl242*
		sudo rm -rf ./project_build_i686/IntelCE/root/etc/Wireless/CL242
		rm -rf project_build_i686/IntelCE/netconf_wifi_ap-*/.built
		sudo rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
		sudo rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked
	fi

	cd $CLR
	rm -rf clr_package_release/$PACKAGE
	make $PACKAGE platform=$PLATFORM

	cd $HP_LOCATION
		tar xf SOURCE_CODE_celeno_clr_package_*_cl242_*.tar.bz2
		cd celeno_clr_package*_cl242_*

	if [ "$sdktype" = "YOCTO" ] ; then
		sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = $(HOME)/work/yocto_p6_ccache/i586-poky-linux-#' src/celeno.mk
		export CCACHE_PATH=${SDK}/build/tmp/sysroots/x86_64-linux/usr/bin/core2-32-poky-linux:$PATH
	else
		export CCACHE_PATH=$IntelCE_path/build_i686/i686-linux-elf/bin:/opt/buildroot-gcc342/bin:$PATH
	fi

	make

	if [ "$sdktype" = "YOCTO" ] ; then
		cd $SDK
		rm -rf ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL || true
		mkdir -p ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL
		tar xvf ${CLR}/clr_package_release/$PACKAGE/*/celeno_clr_package_*_$PACKAGE_*/build/*/$PACKAGE"_"host_pkg-*-*.tar -C ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL
	else
		tar xf build/$PLATFORM/$PACKAGE"_host_pkg"-$PLATFORM.tar -C $SDK
		cd $SDK
		add_packages "package/$PACKAGE"
	fi
}

cl242_23_pre()
{
	cl242_pre
}

cl242_23_CM_pre()
{
	cl242_pre
}

cl242_24_pre()
{
	cl242_pre
}

cl242_25_pre()
{
	cl242_pre
}

cl242_25_new_pre()
{
	cl242_pre
}

# Cleaning and unpacking functions for CLR260 host package platform ST_NOS
clr260_st_nos_pre() {
	export PACKAGE=clr260
	export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM

	cd $CLR
	rm -rf clr_package_release/$PACKAGE
	make $PACKAGE platform=$PLATFORM
	echo "make $PACKAGE platform=$PLATFORM done"

	echo "HP_LOCATION=$HP_LOCATION"
	cd $HP_LOCATION
	tar xf SOURCE_CODE_celeno_clr_package_*_clr260"_"$PLATFORM.tar.bz2

	cd celeno_clr_package_*_$PACKAGE"_"$PLATFORM/
	make
	cp -r build/ST_NOS/* $SDK/vendor/celeno/celeno_wlan/$PACKAGE/etc/
}

# Cleaning and unpacking functions for CLR260 host package
clr260_pre() {
	rm -rf aux
	cd $SDK
	echo "SDK=$SDK"
	rm -f clr260_host_pkg-*.*
	rm -f clr_host_pkg-$platform.tar
	rm -f $PACKAGE-GA.tgz
	rm -rf ./package/clr260
	rm -rf ./package/clr260-GA
	rm -rf ./package/clr_rpc_wlan_config
	rm -rf ./package/clr_rev_rpc_wlan_config
	rm -rf ./project_build_i686/IntelCE/clr260*
	rm -rf ./project_build_i686/IntelCE/clr260-GA
	rm -rf ./project_build_i686/IntelCE/clr_rpc_wlan_config-260
	rm -rf ./project_build_i686/IntelCE/clr_rev_rpc_wlan_config-260
	sudo rm -rf ./project_build_i686/IntelCE/root/etc/Wireless/CLR260
	rm -rf project_build_i686/IntelCE/netconf_wifi_ap-*/.built
	rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
	rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked

	cd $CLR
	echo "CLR=$CLR"
	rm -rf clr_package_release/$PACKAGE
	make $PACKAGE platform=$PLATFORM
	echo "make $PACKAGE platform=$PLATFORM done"

	cd $HP_LOCATION
	echo "HP_LOCATION=$HP_LOCATION"
	tar xf SOURCE_CODE_celeno_clr_package_*_$PACKAGE"_"$PLATFORM.tar*

	cd celeno_clr_package_*_$PACKAGE"_"$PLATFORM/
	make
	tar xf build/$PLATFORM/$PACKAGE"_host_pkg"-$platform.tar.bz2 -C $SDK
	if [ $PLATFORM == "ARRIS" ] ; then
		echo "============================ARRIS============================"
		tar xf build/$PLATFORM/clr_rpc_wlan_config.tar.bz2 -C $SDK
		tar xf build/$PLATFORM/clr_rev_rpc_wlan_config.tar.bz2 -C $SDK
	fi

	cd $SDK
	add_packages "package/$PACKAGE"

	if [ $PLATFORM == "ARRIS" ] ; then
		add_packages "package/clr_rpc_wlan_config"
		add_packages "package/clr_rev_rpc_wlan_config"
	fi

}

# Cleaning and unpacking functions for CLR260 host package, freeze branch
clr260f_pre() {
	clr260_pre
}

# Cleaning and unpacking functions for CLR2200 host package
cl2200_pre() {
	cd $SDK
	if [ "$sdktype" = "YOCTO" ] ; then
		rm -rf ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL || true
	else
		rm -f cl2200_host_pkg-*.*
		rm -rf ./package/cl2200
		rm -rf ./project_build_i686/IntelCE/cl2200*
		sudo rm -rf ./project_build_i686/IntelCE/root/etc/Wireless/CL2200
		rm -rf project_build_i686/IntelCE/netconf_wifi_ap-*/.built
		sudo rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
		sudo rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked
	fi

	cd $CLR
	rm -rf clr_package_release/$PACKAGE
	make $PACKAGE platform=$PLATFORM
	echo "make $PACKAGE platform=$PLATFORM done"
	cd $HP_LOCATION
	tar xf SOURCE_CODE_celeno_clr_package_*_$PACKAGE"_"$PLATFORM.tar*
	cd celeno_clr_package_*_$PACKAGE"_"$PLATFORM/
	make
	tar xf build/$PLATFORM/$PACKAGE"_"host_pkg-*-$platform.tar* -C $SDK

	cd $SDK
	add_packages "package/$PACKAGE"
}

cl2200_CM_pre()
{
	cl2200_pre
}

###############################################################################
# Cleaning and unpacking functions for CL2330 host package
cl2330_pre() {
	cd $SDK
	rm -f cl2330_host_pkg-*.*
	rm -rf ./package/cl2330
	rm -rf ./project_build_i686/IntelCE/cl2330*
	sudo rm -rf ./project_build_i686/IntelCE/root/etc/Wireless/CL2330
	rm -rf project_build_i686/IntelCE/netconf_wifi_ap-*/.built
	rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
	rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked
	rm -rf $HP_LOCATION/celeno_clr_package_$PACKAGE"_"$PLATFORM/

	cd $CLR
	./make_CL2330_release.sh $PLATFORM
	tar xf SOURCE_CODE_celeno_clr_package_$PACKAGE"_"$PLATFORM.tar.bz2

	cd celeno_clr_package_$PACKAGE"_"$PLATFORM/
	if [ "$sdktype" = "YOCTO" ] ; then
		sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = $(HOME)/work/yocto_p6_ccache/i586-poky-linux-#' src/celeno.mk
		export CCACHE_PATH=${SDK}/build/tmp/sysroots/x86_64-linux/usr/bin/core2-32-poky-linux:$PATH
	else
		export CCACHE_PATH=$IntelCE_path/build_i686/i686-linux-elf/bin:/opt/buildroot-gcc342/bin:$PATH
	fi

	make

	echo "pkgonly=$pkgonly"
	if [ "$pkgonly" = "yes" ] ; then
		echo "exit 1"
		exit 1
	fi

	if [ "$sdktype" = "YOCTO" ] ; then
		cd $SDK
		rm -rf ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL || true
		mkdir -p ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL
		tar xvf ${CLR}/celeno_clr_package_$PACKAGE_*/build/*/$PACKAGE"_host_pkg"-*-*-*.t* -C ./build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/$CL
	else
		tar xf build/$PLATFORM/cl2330_host_pkg-*-*-*.tar -C $SDK
		cd $SDK
		add_packages "package/$PACKAGE"
	fi
}

cl2330_24_CM_stable_pre()
{
	cl2330_pre
}

cl2330_24_CM_pre()
{
	cl2330_pre
}

cl2330_24_pre()
{
	cl2330_pre
}

cl2330_25_pre()
{
	cl2330_pre
}

cl2330_25_new_pre()
{
	cl2330_pre
}

cl2330_23_pre()
{
	cl2330_pre
}

cl2330_23_CM_pre()
{
	cl2330_pre
}

###############################################################################
# Cleaning and unpacking functions for CL2330 host package platform ST_NOS
cl2330_st_nos_pre() {
	export PACKAGE=cl2330
	export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM

	rm -rf $HP_LOCATION/celeno_clr_package_$PACKAGE"_"$PLATFORM/

	cd $CLR
	./make_CL2330_release.sh $PLATFORM
	tar xf SOURCE_CODE_celeno_clr_package_$PACKAGE"_"$PLATFORM.tar.bz2

	cd $CLR/celeno_clr_package_$PACKAGE"_"$PLATFORM/
	make
	cp -r build/ST_NOS/* $SDK/vendor/celeno/celeno_wlan/$PACKAGE/etc/
}

usage()
{
	echo "Possible values: SAMSUNG_PUMA6 CBN_MERCURY ATM2 CELENO CELENO_DEMO Celeno_demo CISCO_PUMA6 HAIER ARRIS CBN CBN_INTELP6 CBN_KDG ST_NOS CCN_2"
	echo "Possible to choose short names: eMTA HAIER"
	echo "Ex.: ./p6-pro.sh cl2400_4.7.x CBN_P6_YOCTO cl242_25_new CBN_INTELP6_YOCTO cgiweb CBN_P6_YOCTO_CL2400_CL242"
	echo "Ex.: ./p6-pro.sh cl2400 CBN_P6_YOCTO_CM cl242_25_new CBN_INTELP6_YOCTO cgiweb CBN_P6_YOCTO_CL2400_CL242"
	echo "Ex.: ./p6-pro.sh cl2330_25_new CBN_MERCURY_YOCTO cl242_25_new CBN_INTELP6_YOCTO cgiweb CBN_P6_YOCTO_CL2330_CL242"
	echo "Ex.: ./p6-pro.sh cl242 HAIER cl2200 HAIER"
	echo "Ex.: ./p6-pro.sh HAIER"
	echo "Ex.: ./p6-pro.sh cl2330 CBN_MERCURY cl242 CBN_INTELP6"
	echo "Ex.: ./p6-pro.sh CBN"
	echo "Ex.: ./p6-pro.sh eMTA"
	echo "Ex.: ./p6-pro.sh Celeno_Demo_haier_cgiweb_android"
	echo "Ex.: ./p6-pro.sh Celeno_Demo_cbn_cgiweb"
	echo "Ex.: ./p6-pro.sh ARRIS"

}

relink_sdk()
{
	echo "Remove current link SDK"
	sudo rm -rf /mnt/cernd/sw/clr240_kernels/SAMSUNG_PUMA6/SDK_4.3.0.37
	echo "Create link to SDK. Set new SDK path:$1"
	sudo mkdir -p /mnt/cernd/sw/clr240_kernels/SAMSUNG_PUMA6/SDK_4.3.0.37
	sudo ln -s $1 /mnt/cernd/sw/clr240_kernels/SAMSUNG_PUMA6/SDK_4.3.0.37/IntelCE-0.35.14073.342867
}

#$1 $2 $3
relink_sdk2()
{
	echo "Remove current link SDK"
	sudo rm -rf $1
	echo "Create link to SDK. Set new SDK path:$1"
	sudo mkdir -p $1
	sudo ln -s $3 $1/$2
}

proc_platform()
{
	sdktype=SDK
	case $1 in
	SAMSUNG_PUMA6) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=samsung_puma6
		relink_sdk $SDK
	;;

	CBN_P6_YOCTO) echo "Choosen platform $1: SDK Intel-6.1.1.21 yocto"
		export sdk=6.1.1.21.yocto
		export SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga
		export PLATFORM=CBN_P6_YOCTO
		export platform=cbn_p6_yocto
		sdktype=YOCTO
	;;

	CBN_P6_YOCTO_CM) echo "Choosen platform $1: SDK Intel-6.1.1.21 yocto"
		export sdk=6.1.1.21.yocto
		export SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga
		export PLATFORM=CBN_P6_YOCTO_CM
		export platform=cbn_p6_yocto
		sdktype=YOCTO
	;;

	CBN_INTELP6) echo "Choosen platform $1: SDK 0.35"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=cbn_intelp6
		relink_sdk $SDK
	;;

	CBN_INTELP6_CM) echo "Choosen platform CBN_INTELP6: SDK 0.35.cgiweb"
		export sdk=0.35.cgiweb
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export PLATFORM=CBN_INTELP6
		export platform=cbn_intelp6
		relink_sdk $SDK
	;;

	CBN_INTELP6_YOCTO) echo "Choosen platform $1: SDK Intel-6.1.1.21 yocto"
		export sdk=6.1.1.21.yocto
		export SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga
		export PLATFORM=CBN_INTELP6_YOCTO
		export platform=cbn_intelp6
		sdktype=YOCTO
	;;

	CBN_MERCURY) echo "Choosen platform CBN_MERCURY"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=cbn_mercury
		export PLATFORM=CBN_MERCURY
		relink_sdk $SDK
	;;

	CBN_MERCURY_CM) echo "Choosen platform CBN_MERCURY"
		export sdk=0.35.cgiweb
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export PLATFORM=CBN_MERCURY
		export platform=cbn_mercury
		relink_sdk $SDK
	;;

	CBN_MERCURY_YOCTO) echo "Choosen platform $1: SDK Intel-6.1.1.21 yocto"
		export sdk=6.1.1.21.yocto
		export SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga
		export platform=cbn_mercury
		export PLATFORM=CBN_MERCURY_YOCTO
		sdktype=YOCTO
	;;

	CBN_MERCURY_YOCTO_pkg) echo "Choosen platform $1: SDK Intel-6.1.1.21 yocto"
		export sdk=6.1.1.21.yocto
		export SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga
		export platform=cbn_mercury
		export PLATFORM=CBN_MERCURY_YOCTO
		sdktype=YOCTO
		pkgonly=yes
	;;

	ST_NOS) echo "Choosen platform $1"
		export sdk=st_nos
		export SDK=$SDKDIR/ST_RG_INT_10.0_RC1_CSL_NOS
		export platform=st_nos
		export DIST=STMB2147_NOS
		export LIC=jpkg_i686.lic
		relink_sdk2 /home/developer/work/STRG_env/STRG_8.5 ST_RG_INT_8.5-Celeno $SDK
	;;

	CBN_KDG) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=cbn_kdg
		relink_sdk $SDK
	;;

	CBN) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=cbn
		relink_sdk $SDK
	;;

	ATM2) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=atm2
		relink_sdk $SDK
	;;

	Celeno) echo "Choosen platform $1"
		export sdk=0.5
		export SDK=$SDKDIR/5.0.18.cgiweb/IntelCE-0.5.14491.347720
		export platform=celeno
		relink_sdk $SDK
	;;

	CELENO) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=celeno
		relink_sdk $SDK
	;;

	CELENO_DEMO) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=celeno_demo
		relink_sdk $SDK
	;;

	NOS) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=nos
		relink_sdk2 /home/developer/work/intel_sdk/SDK_4.3.0.37 IntelCE-0.35.14073.342867 $SDK
	;;

#	Celeno_demo) echo "Choosen platform $1"
#		export sdk=0.5
#		export SDK=$SDKDIR/5.0.18.cgiweb/IntelCE-0.5.14491.347720
#		export platform=celeno_demo
#		relink_sdk $SDK
#	;;

#	Celeno_demo) echo "Choosen platform $1"
#		export sdk=0.5
#		export SDK=$SDKDIR/5.0.33.cgiweb/IntelCE-5.0.15161.349400
#		export platform=celeno_demo
#		relink_sdk $SDK
#	;;

	Celeno_demo_cbn) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=celeno_demo_cbn
		relink_sdk $SDK
	;;

	Celeno_demo) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=celeno_demo
		relink_sdk $SDK
	;;

#	Celeno_demo_haier) echo "Choosen platform $1"
#		export sdk=0.35
#		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
#		export platform=Celeno_demo_haier
#		relink_sdk $SDK
#	;;

	Celeno_demo_haier) echo "Choosen platform $1"
		export sdk=0.5
		export SDK=$SDKDIR/5.0.18.cgiweb/IntelCE-0.5.14491.347720
		export platform=celeno_demo_haier
		relink_sdk $SDK
	;;

	CL2330+CL242_ATM_2_0_BS) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=puma6
		relink_sdk $SDK
	;;

	CL2200+CL242_ATM_2_0_BS) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=puma6
		relink_sdk $SDK
	;;

	CL2200+CL242_ATM_2_0) echo "Choosen platform $1"
		export sdk=0.5
		export SDK=$SDKDIR/5.0.18.cgiweb/IntelCE-0.5.14491.347720
		#export SDK=$SDKDIR/5.0.33.cgiweb/IntelCE-5.0.15161.349400
		export platform=puma6
		relink_sdk $SDK
	;;

	CL2200+CL242_ATM_2_0_CM) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=puma6
		relink_sdk $SDK
	;;

	CL2330+CLR260_ATM_2_0_BS) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=puma6
		relink_sdk $SDK
	;;

	CL2330+CLR260_CM) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=puma6
		relink_sdk $SDK
	;;

	CL2330+CL242_ATM_2_0_CM) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35.cgiweb/IntelCE-0.35.14073.342867
		export platform=puma6
		relink_sdk $SDK
	;;

	CBN_P6_YOCTO_CL2400_CL242) echo "Choosen platform $1"
		export sdk=6.1.1.21.yocto
		export sdktype=YOCTO
		export SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga
		export PLATFORM=CBN_P6_YOCTO_CL2400_CL242
		export platform=cbn_p6_yocto_cl2400_cl242
	;;

	CBN_P6_YOCTO_CL2330_CL242) echo "Choosen platform $1"
		export sdk=6.1.1.21.yocto
		export sdktype=YOCTO
		export SDK=$SDKDIR/Intel-6.1.1.21/r6.1.1-ga
		export PLATFORM=CBN_P6_YOCTO_CL2330_CL242
		export platform=cbn_p6_yocto_cl2330_cl242
	;;

	CCN_2) echo "Choosen platform $1"
		export sdk=0.5
		export SDK=$SDKDIR/5.0.33/IntelCE-5.0.15161.349400
		export platform=puma6
		relink_sdk $SDK
	;;

	CL2200+CL242+Android_ATM_2_0) echo "Choosen platform $1"
		export sdk=0.5
		export SDK=$SDKDIR/5.0.18.cgiweb/IntelCE-0.5.14491.347720
		#export SDK=$SDKDIR/5.0.33.cgiweb/IntelCE-5.0.15161.349400
		export platform=puma6
		relink_sdk $SDK
	;;

	PUMA6) echo "Choosen platform $1"
		export sdk=0.35.CL2400
		export SDK=$SDKDIR/0.35.CL2400/IntelCE-0.35.14073.342867
		export platform=PUMA6
#		relink_sdk2 /home/devel/IntelCE-4.3_cl2400 IntelCE-0.35.14073.342867 $SDK
		relink_sdk2 /home/developer/work/CL2400/SDK_4.3.0.37 IntelCE-0.35.14073.342867 $SDK
	;;

	CISCO_PUMA6) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=cisco_puma6
		relink_sdk $SDK
	;;

	HAIER) echo "Choosen platform $1"
		export sdk=0.5
		#export SDK=$SDKDIR/5.0.18/IntelCE-0.5.14491.347720
		export SDK=$SDKDIR/5.0.33/IntelCE-5.0.15161.349400
		export platform=haier
		relink_sdk $SDK
	;;

	CCN) echo "Choosen platform $1"
		export sdk=0.5
		export SDK=$SDKDIR/5.0.18/IntelCE-0.5.14491.347720
		export platform=ccn
		relink_sdk $SDK
	;;

	ARRIS) echo "Choosen platform $1"
		export sdk=0.35.arris
		export SDK=$SDKDIR/0.35.ARRIS/IntelCE-0.35.14073.342867
		export platform=arris
		relink_sdk $SDK
	;;

	SAMSUNG_6400) echo "Choosen platform $1"
		export sdk=0.35
		export SDK=$SDKDIR/0.35-kernel-3.12.42/IntelCE-0.35.14073.342867
#		export SDK=$SDKDIR/0.35/IntelCE-0.35.14073.342867
		export platform=puma6
		relink_sdk $SDK
#		relink_sdk2 /mnt/cernd/sw/clr250_kernels/samsung/CELENO_RELEASE/CELENO_RELEASE/prod Release $SDK
	;;

	*)
		echo "Bad PLATFORM name. Possible value: SAMSUNG_PUMA6 CBN_MERCURY ATM2 CELENO CELENO_DEMO Celeno_demo CISCO_PUMA6 HAIER ARRIS CBN CBN_INTELP6 CBN_KDG ST_NOS CCN_2"
		echo "Possible to choose short names: eMTA HAIER"
		echo "Ex.: ./p6-pro.sh cl242 HAIER cl2200 HAIER"
		echo "Ex.: ./p6-pro.sh HAIER"
		echo "Ex.: ./p6-pro.sh cl2330 CBN_MERCURY cl242 CBN_INTELP6"
		echo "Ex.: ./p6-pro.sh eMTA"
		echo "Ex.: ./p6-pro.sh Celeno_Demo_haier_cgiweb_android"
		echo "Ex.: ./p6-pro.sh Celeno_Demo_cbn_cgiweb"
		echo "Ex.: ./p6-pro.sh ARRIS"
		exit
		;;
	esac
}

proc_package()
{
	case $1 in
	cgiweb)
		echo "Choosen module $PACKAGE"
		export CLR=$SRCDIR/cgiweb
		export HP_LOCATION=$CLR/celeno_package_cgiweb_PUMA6
		;;

	cl2330)
		echo "Choosen module $PACKAGE"
		export BRANCH=5.2.x
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_23)
		export PACKAGE=cl2330
		echo "Choosen module $PACKAGE v23"
		export BRANCH=5.2.x_mercury_23_freeze
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_23_CM)
		export PACKAGE=cl2330
		echo "Choosen module $PACKAGE v23 CM"
		export BRANCH=5.2.x_mercury_23_freeze_CM
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_24)
		export PACKAGE=cl2330
		echo "Choosen module $PACKAGE v24"
		export BRANCH=5.2.x_mercury_24_freeze
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_25)
		export PACKAGE=cl2330
		echo "Choosen module $PACKAGE v25"
		export BRANCH=5.2.x_mercury_25_freeze
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_25_new)
		export PACKAGE=cl2330
		echo "Choosen module $PACKAGE v25_new"
		export BRANCH=5.2.x_mercury_25_new
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_24_CM)
		export PACKAGE=cl2330
		echo "Choosen module $PACKAGE v24 CM"
		export BRANCH=5.2.x_mercury_24_freeze_CM
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_24_CM_stable)
		export PACKAGE=cl2330
		echo "Choosen module $PACKAGE v24 CM"
		export BRANCH=5.2.x_mercury_24_freeze_CM_stable
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2330
		;;

	cl2330_st_nos)
		echo "Choosen module $PACKAGE"
		export BRANCH=5.2.x
		export CLR=$SRCDIR/$BRANCH/CL2330
		export HP_LOCATION=$CLR/clr_package_release/cl2330/$PLATFORM
		CL=CL2330
		;;

	clr240|cl242)
		echo "Choosen module $PACKAGE"
		export BRANCH=6.70.0xx
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		;;

	cl242_23)
		export PACKAGE=cl242
		echo "Choosen module $PACKAGE v23"
		export BRANCH=6.70.0xx_mercury_23_freeze
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL242
		;;

	cl242_23_CM)
		export PACKAGE=cl242
		echo "Choosen module $PACKAGE v23 CM"
		export BRANCH=6.70.0xx_mercury_23_freeze_CM
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL242
		;;

	cl242_24)
		export PACKAGE=cl242
		echo "Choosen module $PACKAGE v24"
		export BRANCH=6.70.0xx_mercury_24_freeze
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL242
		;;

	cl242_25_new)
		export PACKAGE=cl242
		echo "Choosen module $PACKAGE v25_new"
		export BRANCH=6.70.0xx_mercury_25_new
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL242
		;;

	clr250)
		echo "Choosen module $PACKAGE"
		export BRANCH=6.60.0xx
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		;;

	clr260)
		echo "Choosen module $PACKAGE"
		export BRANCH=6.72.1xx
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		;;

	clr260_st_nos)
		echo "Choosen module $PACKAGE"
		export BRANCH=6.72.1xx
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/clr260/$PLATFORM
		;;

	clr260f)
		export PACKAGE=clr260
		echo "Choosen module $PACKAGE"
		export BRANCH=6.72.1xx_arris_freeze
		export CLR=$SRCDIR/$BRANCH/sdk
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		;;

	cl2200)
		echo "Choosen module $PACKAGE"
		export BRANCH=6.84.0xx
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2200
		;;

	cl2200_CM)
		export PACKAGE=cl2200
		echo "Choosen module $PACKAGE CM"
		export BRANCH=6.85.0xx_comtrend_CM
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2200
		;;

	cl2400_b0)
		export PACKAGE=cl2400
		echo "Choosen module $PACKAGE"
		export BRANCH=4.0.0_A0_BU_merge_B0
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2400
		;;

	cl2400)
		export PACKAGE=cl2400
		echo "Choosen module $PACKAGE"
		export BRANCH=4.6.x
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2400
		;;

	cl2400_4.7.x)
		export PACKAGE=cl2400
		echo "Choosen module $PACKAGE"
		export BRANCH=4.7.x
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		CL=CL2400
		;;

	tanami_plus)
		echo "Choosen module $PACKAGE"
		export BRANCH=6.70.0xx
		export CLR=$SRCDIR/$BRANCH
		export HP_LOCATION=$CLR/clr_package_release/$PACKAGE/$PLATFORM
		;;

	*)	echo "Bad package name $1. Possible value: cl2330 clr240 cl242 clr260 clr250 cl2200" ; exit
		;;
	esac
}

proc_short()
{
	case $1 in
	eMTA|CBN|CBN_MERCURY)
		short=$1
		echo "$short compiling"
		pre cl2330 CBN_MERCURY
		pre cl242 CBN_INTELP6
		;;

	HAIER)
		short=HAIER
		echo "$short compiling"
		pre cl242 HAIER
		pre cl2200 HAIER
		;;

	CBN_KDG)
		short=CBN_KDG
		echo "$short compiling"
		pre cl2330 CBN_KDG
		pre clr260 CBN
		;;

	CCN)
		short=CCN
		echo "$short compiling"
		pre cl242 CCN
		pre cl2200 CCN
		;;

	Celeno_Demo_haier_cgiweb_android)
		short=Celeno_Demo_haier_cgiweb_android
		echo "$short compiling"
		pre cl242 Celeno_demo_haier
		pre cl2200 Celeno_demo
		pre cgiweb CL2200+CL242+Android_ATM_2_0
		;;

	Celeno_Demo_cbn_cgiweb)
		short=Celeno_Demo_cbn_cgiweb
		echo "$short compiling"
		pre cl242 Celeno_demo_cbn
		pre cl2330 CELENO_DEMO
		pre cgiweb CL2330+CL242_ATM_2_0_BS
		;;

	ARRIS)
		short=ARRIS
		echo "$short compiling"
		pre clr260 ARRIS
		;;

	ST_NOS)
		export SDK=$SDKDIR/ST_RG_INT_10.0_RC1_CSL_NOS

		short=ST_NOS

		pre cl2330_st_nos ST_NOS
		pre clr260_st_nos ST_NOS
		;;

	?)
		usage
		;;

	*)	;;
	esac
}

###############################################################################
# Pre-/postuImage procedures
pre()
{
	export PACKAGE=$1
	export PLATFORM=$2

	proc_platform $2
	proc_package $1

	if [ -z $SDK ] ; then
		echo "Please specify put your SDKs in specific folder"
		echo "Ex.: PATH_TO_SDK_DIR/0.35/Intel-..."
		echo "     PATH_TO_SDK_DIR/0.35.ARRIS/Intel.."
		echo "     PATH_TO_SDK_DIR/0.5/Intel.."
		exit
	fi

	platforms+=($PLATFORM)
	packages+=($PACKAGE)

	$1_pre
	notify-send -i starred "host package $PACKAGE $BRANCH $PLATFORM" "build done in $SECONDS seconds"
#	if [[ $PLATFORM == "ST_NOS" ]] ; then
#		echo -n
#	else
		export PACKAGE=
		export PLATFORM=
		export platform=
#	fi
}

###############################################################################
# This routine adds specific package to the Config.IntelCE.in
add_packages() {
	if ! grep -q "source $1" package/Config.IntelCE.in; then
		echo -e '\e[1;34mEnabling' $1 'package\e[00m'
		ls -1d $1* 2>/dev/null | sed 's#.*#source &/Config.in#' >>package/Config.IntelCE.in
		make defconfig
	fi
}
###############################################################################


###############################################################################
# uImage building routines
uImage() {
	clean_uImage
	make_uImage
	exit_status=$?
	return $exit_status
}

clean_uImage() {
	if [ "$sdktype" = "YOCTO" ] ; then
		(cd $SDK/build/tmp/deploy/images/intelce ;
		rm -fv \
		app_cpu_efi_partition.20??????????.bin \
		app_cpu_efi_partition.20??????????.bin \
		bzImage.20??????????.osmanifest \
		core-image-cougarmountain-cougarmountain-20????????????.intelce-repo-manifest \
		core-image-cougarmountain-cougarmountain-20????????????.rootfs.manifest \
		core-image-cougarmountain-cougarmountain-20????????????.rootfs.tar.bz2 \
		core-image-cougarmountain-cougarmountain-20????????????.rootfs.squashfs \
		bzImage.2017???????? \
		app_cpu_rootfs_partition.20??????????.bin \
		app_cpu_rootfs_partition.20??????????.bin.osmanifest \
		app_cpu_image_sec.20??????????.uimg \
		app_cpu_image.20??????????.uimg \
		core-image-gateway-intelce-20????????????.rootfs.tar.bz2 \
		core-image-gateway-intelce-20????????????.rootfs.manifest \
		uimage-intelce-20????????????.intelce-repo-manifest \
		|| true)
		echo "$sdktype: clean uImage skipped"
	else
		echo "clean_uImage"
		rm -rf project_build_i686/IntelCE/netconf_wifi_ap-*/.built
		rm -rf project_build_i686/IntelCE/targetFS_gateway-*/.built
		rm -rf project_build_i686/IntelCE/uImage-*/building/.unpacked
	fi
}

make_uImage() {
	if [ "$sdktype" = "YOCTO" ] ; then
		cd $SDK
		source yocto/oe-init-build-env
		bitbake uimage || exit 1
		imagesize=`ls -l tmp/deploy/images/intelce/appcpuRootfs.img | awk '{print $5}'`
		echo "Image size is $imagesize (max 17825792)" >&2
		if [ $imagesize -gt 17825792 ]; then
			echo "Image size is too big!!!" >&2
			exit 1
		fi
	else
		sudo make all && sudo make uImage-clean && sudo make uImage
	fi
}

###############################################################################
post() {
	if [[ $PLATFORM == "ST_NOS" ]] ; then
		return 0
	fi

	if [ "$sdktype" = "YOCTO" ] ; then
		cd $SDK
		BINARIES=build/tmp/deploy/images/intelce
		FS=build/tmp/work/core2-32-poky-linux/uimage/1.0-r0/targetFS_gateway/etc/Wireless/
	else
		BINARIES=binaries/IntelCE
		FS=project_build_i686/IntelCE/root/etc/Wireless/
	fi

	cp $BINARIES/{bzImage,appcpuImage,appcpuRootfs.img} /tftpboot/
	date
	ls -l /tftpboot/{bzImage,appcpuImage,appcpuRootfs.img}

	echo -n "Built packages    : "
	echo ${packages[@]}
	echo -n "PACKAGES in Image : "
	ls --color $FS
	if [[ -n $short ]] ; then
		echo "$short built"
	fi
	echo -n "PLATFORMS         : "
	echo ${platforms[@]}
	echo "SDK version       : $SDK"
	if [ "$sdktype" = "YOCTO" ] ; then
		imagesize=`ls -l $SDK/build/tmp/deploy/images/intelce/appcpuRootfs.img | awk '{print $5}'`
	echo "Image size        : $imagesize/17825792"
	fi
	echo "CLR branch        : $CLR"
	notify-send -i emblem-default "Image" "sdk.$sdk $short build done in $SECONDS seconds"
	echo "This build took $SECONDS seconds"
	return $exit_status
}
###############################################################################

check_env()
{
	if [ -z $SRCDIR ] ; then
		SRCDIR=`pwd`
	fi

	if [ ! -d $SRCDIR ] ; then
		echo "SRCDIR=$SRCDIR"
		echo "$SRCDIR not exist"
		echo "Please specify path to source code root dir"
		echo "Ex. export SRCDIR=PATH_TO_SRC_DIR"
		exit
	fi

	if [ -z $SDKDIR ] ; then
		SDKDIR=`pwd`/SDK
	fi

	if [ ! -d $SRCDIR ] ; then
		echo "$SDKDIR not exist"
		echo "Please specify path to SDK root dir"
		echo "Ex.: export SDKDIR=PATH_TO_SDK_DIR"
		exit
	fi
}

main() {
	SECONDS=0
	declare -a platforms
	declare -a packages
	check_env
	numargs=$#

	if [[ $numargs == 0 ]] ; then
		usage
		exit
	else if [[ $numargs == 1 ]] ; then
			echo "BUILD $1"
			proc_short $1
		else
			for ((i = 1 ; i <= numargs ; i += 2))
			{
				if [[ -n $1 && -n $2 ]] ; then
					echo "BUILD $1 $2"
						pre $1 $2
						fi
						shift 2
			}
		fi
	fi

	echo "PLATFORM=$PLATFORM PACKAGE=$PACKAGE"
	uImage
	if [[ $PLATFORM == "ST_NOS" ]] ; then
		date
		echo "Build ST_NOS in $SECONDS seconds"
	else
		post
	fi
}

main $@
