#!/bin/bash

PREFIX=`pwd`
PREFIX=$PREFIX/arm

mkdir gmp/build; cd gmp/build
../configure --prefix=$PREFIX/gmp --disable-shared --enable-static
make; make install
cd ../../

mkdir mpfr/build; cd mpfr/build
../configure --prefix=$PREFIX/mpfr --with-gmp=$PREFIX/mpfr --disable-shared --enable-static
make; make install
cd ../../

mkdir mpc/build; cd mpc/build
../configure --prefix=$PREFIX/mpc --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --disable-shared --enable-static
make; make install
cd ../../

mkdir binutils/build; cd binutils/build
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --disable-nls --disable-shared --disable-threads --with-gcc --with-gnu-as --with-gnu-ld
make; make install
cd ../../

mkdir gcc/build; cd gcc/build
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --enable-languages=c --with-newlib --disable-nls --disable-shared --disable-threads --with-gnu-as --with-gnu-ld --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --without-headers
make all-gcc; make install-gcc
cd ../../

mkdir newlib/build; cd newlib/build
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-nls
make; make install
cd ../../

cd gcc
rm -rf build
mkdir build; cd build
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --enable-interwork --enable-multilib --enable-languages=c,c++ --with-newlib --disable-nls --disable-shared --disable-threads --with-gnu-as --with-gnu-ld --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc
make; make install
cd ../../

mkdir gdb/build; cd gdb/build
../configure --prefix=$PREFIX/arm-none-eabi --target=arm-none-eabi --disable-nls --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --with-libexpat
make; make install
cd ../../
