#!/bin/bash

PWD=`pwd`
TARGET=arm-eabi
PREFIX=$PWD/$TARGET
LEVEL=4

prepare() {
	cd $PWD
	if [ ! -z $1 ]; then
		CUR=$1
		CURB=$CUR/build
		if [ -d "$CURB" ]; then
			rm -Rf $CURB
		fi
		mkdir $CURB ; cd $CURB
	fi
}

if [ -d "$PREFIX" ]; then
	rm -Rf $PREFIX
fi
mkdir $PREFIX ; cd $PREFIX

prepare gmp
../configure --prefix=$PREFIX/gmp --disable-shared --enable-static
make -j $LEVEL ; make install

prepare mpfr
../configure --prefix=$PREFIX/mpfr --with-gmp=$PREFIX/gmp --disable-shared --enable-static
make -j $LEVEL ; make install

prepare mpc
../configure --prefix=$PREFIX/mpc --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --disable-shared --enable-static
make -j $LEVEL ; make install

prepare binutils
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --enable-interwork --enable-multilib --disable-nls --disable-shared --enable-threads --with-gcc --with-gnu-as --with-gnu-ld
make -j $LEVEL ; make install

prepare gcc
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --enable-interwork --enable-multilib --enable-languages=c --with-newlib --disable-nls --disable-shared --enable-threads --with-gnu-as --with-gnu-ld --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --without-headers
make all-gcc ; make install-gcc

prepare newlib
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls
make -j $LEVEL ; make install

prepare gcc
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --enable-interwork --enable-multilib --enable-languages=c,c++ --with-newlib --disable-nls --disable-shared --enable-threads --with-gnu-as --with-gnu-ld --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc
make -j $LEVEL ; make install

prepare gdb
../configure --prefix=$PREFIX/$TARGET --target=$TARGET --disable-nls --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --with-libexpat
make -j $LEVEL ; make install

#finish
cd `PWD`
