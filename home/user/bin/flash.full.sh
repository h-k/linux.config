#!/bin/sh

export CURDIR=${PWD}
cp ${PWD}/arch/arm/boot/zImage ${MMC_BIN_REL}/
cd ${MMC_BIN_REL}/
./umulti2.sh
sudo ./fastboot.sh
cd ${CURDIR}