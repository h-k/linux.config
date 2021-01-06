#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export COV_DIR=cov-$(date +%F)

PACKAGE=cl8000 

readonly ME="${0##*/}"
readonly BUILDSCRIPT="make_cl_release.sh"


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

	rsync -ar --progress --exclude=.repo --exclude=.svn --exclude=.git --exclude=.cscope --delete --delete-excluded -e ssh $ssh_src $dst 1>/dev/null
}

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

build() {
	SECONDS=0
	local src="$1"
	local PLATFORM="$2"
	local _PWD=$PWD

	cd $src

	rm_rf celeno_package_${PACKAGE}_${PLATFORM}

	./"$BUILDSCRIPT" -p "${PLATFORM}" 1>/dev/null

	tar xf SOURCE_CODE_celeno_package_${PACKAGE}_*_${PLATFORM}.tar.gz
	cd celeno_package_${PACKAGE}_${PLATFORM}

	sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = /home/developer/ccache/cl8000/aarch64-linux-gnu-#' src/celeno.mk
	export CCACHE_PATH=/usr/bin:$PATH

	echo "[START COMPILATION ${PACKAGE} ${PLATFORM}}"

	make 1>/dev/null

	mv build cl8000 1>/dev/null
	tar -czf cl8000.tar.bz2 cl8000 1>/dev/null
       
	cd ${_PWD}

	mv ${src}/celeno_package_${PACKAGE}_${PLATFORM}/cl8000.tar.bz2 . 1>/dev/null
}

main() {
	local ssh_src=
	local remote_src=
        local src=
        local dst=
        local plat=

	while getopts "hs:d:p:e:r:" opt; do
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
			r)
				remote_src="$OPTARG"
				;;
		esac
	done

	if [ -z "$ssh_src" ] ; then
		ssh_src=alexander2@172.168.110.142
	fi
	echo "SYNC          : $ssh_src"

	if [ -z "$remote_src" ] ; then
		remote_src=/home/alexander2/repo/celeno-swdb-CL8000-hp/8.0.x
	fi
	echo "REMOTE_SRC    : $remote_src"

	if [ -z "$src" ] ; then
		src=/home/developer/8.0.x
	fi
	echo "LOCAL SOURCES : $src"

	if [ -z "$dst" ]; then
		dst="."
	echo "BUILD DIR     : $src"
	else
	echo "BUILD DIR     : $dst"
	fi

	if [ -z "$plat" ]; then
		plat=HK6030
	fi
	echo "PLATFORM      : $plat"

	sync_sources "${ssh_src}:${remote_src}" $src $dst

	build $src $plat

	scp cl8000.tar.bz2 ${ssh_src}:/tftpboot/cl8000.tar.bz2 1>/dev/null

	dat=`date`
	echo "local lxc hk6030-hk: $dat cl8000: compilation in $SECONDS sec DONE." > notify.txt
	cat ./notify.txt

	scp ./notify.txt ${ssh_src}:/tmp/notify.txt 1>/dev/null

	rm -rf ./notify.txt 1>/dev/null
}


main "$@"
