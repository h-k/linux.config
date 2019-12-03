#!/bin/sh

export CURDIR=${PWD}
cp ${PWD}/arch/arm/boot/zImage ${MMC_BIN_REL}/
cd ${MMC_BIN_REL}/
./umulti2.sh
sudo ./fastboot flash boot boot.img
sudo ./fastboot reboot
cd ${CURDIR}