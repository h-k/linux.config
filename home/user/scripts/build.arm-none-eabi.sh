#!/bin/bash

PREFIX=`pwd`
PREFIX=$PREFIX/arm

prepare() {
	if [ ! -z $1 ]; then
		CUR=$1
		CURB=$CUR/build
		if [ -d "$CURB" ]; then
			rm -Rf $CURB
		fi
		mkdir $CURB ; cd $CURB
	fi
}

prepare gmp
../configure --prefix=$PREFIX/gmp --disable-shared --enable-static
make -j4; make install
cd ../../

prepare mpfr
../configure --prefix=$PREFIX/mpfr --with-gmp=$PREFIX/gmp --disable-shared --enable-static
make -j4; make install
cd ../../

prepare mpc
../configure --prefix=$PREFIX/mpc --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --disable-shared --enable-static
make -j4; make install
cd ../../

prepare binutils
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --disable-nls --disable-shared --enable-threads --with-gcc --with-gnu-as --with-gnu-ld
make -j4; make install
cd ../../

prepare gcc
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --enable-languages=c --with-newlib --disable-nls --disable-shared --enable-threads --with-gnu-as --with-gnu-ld --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --without-headers
make all-gcc -j4; make install-gcc
cd ../../

prepare newlib
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls
make -j4; make install
cd ../../

prepare gcc
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --enable-languages=c,c++ --with-newlib --disable-nls --disable-shared --enable-threads --with-gnu-as --with-gnu-ld --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc
make -j4; make install
cd ../../

prepare gdb
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --disable-nls --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --with-libexpat
make -j4; make install
cd ../../
