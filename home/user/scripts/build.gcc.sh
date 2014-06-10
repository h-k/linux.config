#!/bin/bash

ROOTPWD=`pwd`
TARGET=arm-eabi
PREFIX=$ROOTPWD/$TARGET-build
HOST=`gcc -dumpmachine`
THREADS=2

unset TARGET_GCC_OPTIONS
TARGET_GCC_OPTIONS="$TARGET_GCC_OPTIONS --prefix=$PREFIX/$TARGET"
TARGET_GCC_OPTIONS="$TARGET_GCC_OPTIONS --target=$TARGET"
TARGET_GCC_OPTIONS="$TARGET_GCC_OPTIONS --host=$HOST"
TARGET_GCC_OPTIONS="$TARGET_GCC_OPTIONS --build=$HOST"

unset COMMON_GCC_OPTIONS
COMMON_GCC_OPTIONS="$COMMON_GCC_OPTIONS --with-gnu-as"
COMMON_GCC_OPTIONS="$COMMON_GCC_OPTIONS --with-gnu-ld"
COMMON_GCC_OPTIONS="$COMMON_GCC_OPTIONS --enable-languages=c,c++"
COMMON_GCC_OPTIONS="$COMMON_GCC_OPTIONS --disable-shared"

unset REQUIRED_GCC_OPTIONS
REQUIRED_GCC_OPTIONS="$REQUIRED_GCC_OPTIONS --disable-multilib"
REQUIRED_GCC_OPTIONS="$REQUIRED_GCC_OPTIONS --enable-threads=posix"
REQUIRED_GCC_OPTIONS="$REQUIRED_GCC_OPTIONS --with-gmp=$PREFIX/gmp"
REQUIRED_GCC_OPTIONS="$REQUIRED_GCC_OPTIONS --with-mpfr=$PREFIX/mpfr"
REQUIRED_GCC_OPTIONS="$REQUIRED_GCC_OPTIONS --with-mpc=$PREFIX/mpc"
REQUIRED_GCC_OPTIONS="$REQUIRED_GCC_OPTIONS --with-newlib"

unset EXTRA_GCC_OPTIONS
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --without-ppl"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-nls"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --without-cloog"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-libssp"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-libmudflap"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-libgomp"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-libstdc__-v3"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-sjlj-exceptions"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-tls"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-libitm"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-float=soft"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-fpu=vfp"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-arch=armv5te"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --enable-target-optspace"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-abi=aapcs"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-gcc-version=4.9.0 2014 06 10"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-binutils-version=2.24"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-gmp-version=6.0.0a"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-mpfr-version=3.1.2"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-mpc-version=1.0.2"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-gdb-version=7.7"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --with-sysroot=$PREFIX/sysroot"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --enable-gold"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --disable-gold"
#EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --enable-bootstrap"
EXTRA_GCC_OPTIONS="$EXTRA_GCC_OPTIONS --enable-lto"


prepare() {
	cd $ROOTPWD
	echo "ROOTPWD=$ROOTPWD"
	if [ ! -z $1 ]; then
		CUR=$1
		CURB=$CUR/build
		if [ -d "$CURB" ]; then
			rm -Rf $CURB
		fi
		mkdir $CURB ; cd $CURB
		echo "pwd=`pwd`"
	fi
}

echo "                                     Build options"
echo "                                   TARGET_GCC_OPTIONS"
echo "$TARGET_GCC_OPTIONS"
echo "                                   COMMON_GCC_OPTIONS"
echo "$COMMON_GCC_OPTIONS"
echo "                                  REQUIRED_GCC_OPTIONS"
echo "$REQUIRED_GCC_OPTIONS"
echo "                                    EXTRA_GCC_OPTIONS"
echo "$EXTRA_GCC_OPTIONS"

if [ ! -d "$PREFIX" ]; then
	mkdir $PREFIX
else
	rm -Rf $PREFIX
fi

echo "STAGE 1: gmp"
prepare gmp
../configure --prefix=$PREFIX/gmp --disable-shared --enable-static
make -j $THREADS ; make install

echo "STAGE 2: mpfr"
prepare mpfr
../configure --prefix=$PREFIX/mpfr --with-gmp=$PREFIX/gmp --disable-shared --enable-static
make -j $THREADS ; make install

echo "STAGE 3: mpc"
prepare mpc
../configure --prefix=$PREFIX/mpc --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --disable-shared --enable-static
make -j $THREADS ; make install

echo "STAGE 4: binutils"
prepare binutils
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --enable-interwork --disable-multilib --disable-nls --disable-shared --enable-threads=posix --with-gcc --with-gnu-as --with-gnu-ld --enable-gold
make -j $THREADS ; make install

echo "STAGE 5: gcc --without-headers"
prepare gcc
../configure $TARGET_GCC_OPTIONS $COMMON_GCC_OPTIONS $REQUIRED_GCC_OPTIONS $EXTRA_GCC_OPTIONS --without-headers
make all-gcc -j $THREADS ; make install-gcc

echo "STAGE 6: newlib"
prepare newlib
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --enable-interwork --disable-multilib --with-gnu-as --with-gnu-ld --disable-nls
make -j $THREADS ; make install

echo "STAGE 7: gcc"
prepare gcc
../configure $TARGET_GCC_OPTIONS $COMMON_GCC_OPTIONS $REQUIRED_GCC_OPTIONS $EXTRA_GCC_OPTIONS
make -j $THREADS ; make install

echo "STAGE 8: gdb"
prepare gdb
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --disable-nls --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --with-libexpat
make -j $THREADS ; make install

#finish
cd $ROOTPWD

echo "     _                   "
echo "  __| | ___  _ __   ___  "
echo " / _  |/ _ \| '_ \ / _ \ "
echo "| (_| | (_) | | | |  __/ "
echo " \__,_|\___/|_| |_|\___| "
echo "                         "
echo "                         "

/usr/bin/notify-send "gcc 4.9.0 build done!"
