#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export COV_DIR=cov-$(date +%F)

readonly ME="${0##*/}"
readonly BUILDSCRIPT="make_cl_release.sh"
readonly HPDIR="celeno_package_cl8000_HK6030"
readonly BASE_HP_CONFIG="cl_hp_build.sh"
readonly CELENOMK="src/celeno.mk"

die() {
	echo "ERROR: $1" >&2
	exit "${2:-1}"
}

print_help() {
	cat <<-EOF
	${ME}:
	    -h - print this help
	    -s - set source. Default is "."
	    -d - set destination
	    -p - set platform. Default is HK6030

	Example usage:
	    ./${ME} -s "$HOME/celeno-swdb-CL8000-hp/8.0.x" -d "$HOME/build"

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

	rsync -ar --progress --exclude=.repo --exclude=.svn --exclude=.git --exclude=.cscope --delete --delete-excluded -e ssh $ssh_src $dst
}

build() {
    local src="$1"
    local plt="$2"

    cd $src


    ./"$BUILDSCRIPT" -p "$plt"

#    sed -i -e 's#^\s*DEF_CONF_CROSS_COMPILE.*$#DEF_CONF_CROSS_COMPILE = /home/alexander/ccache/cl8000/aarch64-linux-gnu-#' src/celeno.mk
#    export CCACHE_PATH=/usr/bin/:$PATH
#    make
#    ./"$BUILDSCRIPT" -p "$plt" -m
    cd -
}

main() {
    if [ $# < 1 ]; then
        echo "No options found. Try to execute \"${ME} -h\" for help."
        exit 1
    fi

    local src= dst= plat=

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

    [[ -z "$ssh_src" ]] && die "ssh source path must be specified."

    [[ -z "$src" ]] && die "source path must be specified."

    if [[ -z "$dst" ]]; then
        info "The source path is not specified. The default path will be used."
        dst="."
    fi

    shift $(($OPTIND - 1))

    echo "main ssh=$ssh_src src=$src dst=$dst"

    cd $src

    rm -rf SOURCE_CODE_celeno_package_cl8000_*.tar.gz
    rm -rf celeno_package_cl8000_HK6030/

    cd -

#    sync_sources $ssh_src $src $dst
    build $src ${plat:-HK6030}

    scp ${src}/celeno_package_cl8000_HK6030/cl8000.tar alexander@172.168.110.230:/tftpboot/
    dat=`date`
    echo "packman: $dat cl8000: compilation DONE." > notify.txt
    scp notify.txt alexander@172.168.110.230:/tmp/notify.txt
    rm -rf notify.txt
}

main "$@"
