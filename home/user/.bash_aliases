alias ..='cd ..'
alias a='ls -a'
alias v='vim'
alias arm='make ARCH=arm -j4'
alias rearm='make clean ; make ARCH=arm -j4'
alias oboot='usbboot -f'
alias ram_unpack='gunzip -c ../ramdisk.img | cpio -i'
alias ram_pack='find . | cpio -o -H newc | gzip > ../ramdisk.img'
alias show='git show'
alias blame='git blame'
alias oneline='git log --oneline'
alias lg="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lgr="git log --color --reverse --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gsend='git send-email --smtp-server /usr/bin/msmtp --from "${USER_REAL_NAME} <${TI_MAIL}>" --envelope-sender="${USER_REAL_NAME} <${TI_MAIL}>" --suppress-cc=all'
alias gsendcompose='git send-email --smtp-server /usr/bin/msmtp --from "${USER_REAL_NAME} <${TI_MAIL}>" --envelope-sender="${USER_REAL_NAME} <${TI_MAIL}>" --suppress-cc=all --compose'
alias cpio_pack='find . | cpio -o -H newc > ../newramdisk.cpio'
alias cpio_unpack='cat ../ramdisk.cpio | cpio -i'
