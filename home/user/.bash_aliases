alias ..='cd ..'
alias arm='make ARCH=arm -j4'
alias rearm='make clean ; make ARCH=arm -j4'
alias oboot='usbboot -f'
alias extract='gunzip -c ../ramdisk.img | cpio -i'
alias pack='find . | cpio -o -H newc | gzip > ../ramdisk.img'
alias fetch='git fetch origin'
