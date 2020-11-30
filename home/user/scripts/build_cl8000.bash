#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export COV_DIR=cov-$(date +%F)

PLATFORM=HK6030
PACKAGE=cl8000 

readonly ME="${0##*/}"
readonly BUILDSCRIPT="make_cl_release.sh"
readonly HPDIR="celeno_package_cl8000_HK6030"
readonly BASE_HP_CONFIG="cl_hp_build.sh"
readonly CELENOMK="src/celeno.mk"

#param 1 - dir for deleting
rm_rf()
{
	if [ "$1" != "" ]; then
		mkdir empty_dir
		rsync -a --delete empty_dir/ $1
		rm -rf empty_dir
		rm -rf $1
	fi
}

die() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

info() {
    echo "$ME: $@" >&2
}

edo() {
    info "$@"
    "$@" || die "$* failed"
}

print_help() {
    cat <<-EOF
	${ME}:
	    -h - print this help
	    -s - set source. Default is "."
	    -d - set destination
	    -p - set platform. Default is HK6030
	    -e - set ssh source

	Example usage:
	    ./${ME} -s "$HOME/celeno-swdb-CL8000-hp/8.0.x" -d "$HOME/build"
            ./build_cl8000.bash  -e alexander@172.168.110.230:/home/alexander/repo/celeno-swdb-CL8000-hp/8.0.x -s /home/developer/8.0.x -d /home/developer/8.0.x
EOF
    exit 0
}

# param 1 - ssh where src code locate
# param 2 - path to src code
# param 3 - dst
sync_sources() {
	local ssh_src="$1"
	local src="$2"
	local dst="$3"

	rsync -ar --progress --exclude=.repo --exclude=.svn --exclude=.git --exclude=.cscope --delete --delete-excluded -e ssh $ssh_src $dst &>/dev/null
}

build() {
	local src="$1"
	local plt="$2"

	cd $src

	#    rm -rf celeno_package_cl8000_HK6030
	rm_rf celeno_package_cl8000_HK6030
	./"$BUILDSCRIPT" -p "$plt"

	tar xf SOURCE_CODE_celeno_package_cl8000_*_${PLATFORM}.tar.gz
	cd celeno_package_cl8000_HK6030/

	sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = /home/developer/ccache/cl8000/aarch64-linux-gnu-#' src/celeno.mk
	export CCACHE_PATH=/usr/bin:$PATH

	make

	cd -
}

main() {
	local ssh_src=
        local src=
        local dst=
        local plat=

	while getopts "hs:d:p:e:" opt; do
		case "$opt" in
			s)
				src="$OPTARG"
				;;
			d)
				dst="$OPTARG"
				;;
			h)
				print_help
				;;
			p)
				plat="$OPTARG"
				;;
			e)
				ssh_src="$OPTARG"
				;;
		esac
	done

	if [ -z "$ssh_src" ] ; then
		ssh_src=alexander@172.168.110.230:/home/alexander/repo/celeno-swdb-CL8000-hp/8.0.x
	fi

	if [ -z "$src" ] ; then
		src=/home/developer/8.0.x
	fi

	if [ -z "$dst" ]; then
		info "The source path is not specified. The default path will be used."
		dst="."
	fi

#	shift $(($OPTIND - 1))

	echo "main ssh=$ssh_src src=$src dst=$dst"

	sync_sources $ssh_src $src $dst

	build $src ${plat:-HK6030}

	echo `ls -l ${src}/celeno_package_cl8000_HK6030/cl8000_host_pkg-*-${PLATFORM}.tar.bz2`
	scp ${src}/celeno_package_cl8000_HK6030/cl8000_host_pkg-*-${PLATFORM}.tar.bz2 alexander@172.168.110.230:/tftpboot/cl8000.tar

	dat=`date`
	echo "packman: $dat cl8000: compilation DONE." > notify.txt
	scp notify.txt alexander@172.168.110.230:/tmp/notify.txt
	rm -rf notify.txt
}


main "$@"
