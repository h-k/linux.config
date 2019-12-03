#!/bin/bash
set -e

# for build x86:
install_packages_x86()
{
	echo "install_packages_x86:"
	sudo apt-get -y install gawk texlive-latex-extra pgf \
	latex-xcolor latex-beamer git git-svn subversion libc6-dev-i386 g++ bison \
	flex zlib1g:i386 gettext gperf libncurses5 texinfo fakeroot build-essential \
	zlib1g-dev libncurses5-dev lib32ncurses5-dev doxygen mc \
	libpam0g:i386 libstdc++5 libstdc++5:i386 libstdc++6 libstdc++6:i386 wget diffstat unzip gcc-multilib \
	chrpath socat libsdl1.2-dev curl unifdef iperf nfs-kernel-server nfs-common isc-dhcp-server atftpd \
	vim exuberant-ctags automake libnl1 libnl-dev cscope openssh-server ccache minicom iotop nmap tftp \
	meld kate
	echo "install_packages_x86: DONE"
}

# for build x64:
install_packages_x64()
{
	echo "install_packages_x86_64:"
	sudo apt-get -y install gawk texlive-latex-extra \
	git git-svn subversion g++ bison \
	flex gettext gperf libncurses5 texinfo fakeroot build-essential \
	zlib1g-dev libncurses5-dev doxygen mc \
	libstdc++5 wget diffstat unzip gcc-multilib \
	chrpath socat libsdl1.2-dev curl unifdef iperf nfs-kernel-server nfs-common isc-dhcp-server atftpd \
	vim exuberant-ctags automake cscope openssh-server ccache minicom iotop nmap tftp\
	meld kate
	echo "install_packages_x86_64: DONE"
}


install_packages()
{
	local machine=`uname -m`

	if [ "$machine" = "x86_64" ] ; then
		install_packages_x64
	else
		install_packages_x86
	fi
}

main() {
	SECONDS=0
	numargs=$#

	REPO=`pwd`

	install_packages

	sudo cp -r $REPO/usr/* /usr/

	cp -r $REPO/home/user/* $HOME/
#	cp -r $REPO/home/user/.config/* $HOME/.config/
#	cp -r $REPO/home/user/.local/* $HOME/.local/
#	cp -r $REPO/home/user/.vim/* $HOME/.vim/
#	cp -r $REPO/home/user/.wireshark/* $HOME/.wireshark/

	echo "Tuning done. This took $SECONDS seconds."
}

main $@
