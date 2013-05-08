#!/bin/bash

# Script for repacking system.img with built DDK
# Must be executed from dir with system.img
#
# Please refer
# http://www.omappedia.org/wiki/Android_eMMC_Booting#Modifying_.IMG_Files
# for details

# ---- VARIABLES ----

cur_dir=$(pwd)
my_user=x0187394
simg=./simg2img
makeext4fs=./make_ext4fs
mnt_point=${cur_dir}/system
ddk_dir=$MMC_BIN_REL_TABLET/.ddk
ddk_files=()
files_owners=()

# ---- FUNCTIONS ----

mount_image() {
	echo "---> Mounting original system image..."
	rm -f system.img.raw
	$simg system.img system.img.raw
	sudo umount $mnt_point >/dev/null 2>/dev/null
	sudo rm -rf $mnt_point
	mkdir $mnt_point
	sudo mount -t ext4 -o loop system.img.raw $mnt_point
}

modify_image() {
	echo "---> Searching all DDK files..."
	cd $ddk_dir/system
	ddk_files=($(find . -type f | cut -c3-))
	cd - >/dev/null

	echo "---> Finding out owners..."
	count=${#ddk_files[*]}
	last_index=$(($count-1))
	for i in $(seq 0 $last_index); do
		cur_owners=$(stat -c %u:%g $mnt_point/${ddk_files[$i]} 2>/dev/null)
		if [ $? -ne 0 ]; then
			cur_owners="0:0"
		fi
		files_owners[$i]=$cur_owners
	done

	echo "---> Copying files..."
	sudo cp -Rf $ddk_dir/system/* $mnt_point

	echo "---> Setting owners..."
	for i in $(seq 0 $last_index); do
		sudo chown ${files_owners[$i]} $mnt_point/${ddk_files[$i]}
	done
}

create_image() {
	echo "---> Making new system image..."
	rm -f system.img
	sudo $makeext4fs -s -l 512M -a system system.img $mnt_point
	sudo chown $my_user:$my_user system.img
}

remove_garbage() {
	echo "---> Removing garbage..."
	sudo umount $mnt_point
	sudo rm -rf $mnt_point
	sudo rm -rf system.img.raw
}

# ---- MAIN ----

mount_image
modify_image
create_image
remove_garbage
echo "---> Done!"
