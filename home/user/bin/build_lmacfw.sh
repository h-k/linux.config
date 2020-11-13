#!/bin/sh
set -e

main()
{
	rm -rf lmac_B0_4.7.x_23_GA15/
	rsync -ar --progress --exclude=.repo --exclude=.svn --exclude=.git --delete --delete-excluded -e ssh alexander@172.168.110.230:/home/alexander/repo/4.7.x_23_GA15/lmac_B0_4.7.x_23_GA15 .
	cd lmac_B0_4.7.x_23_GA15/
	./build_asic.sh
	cd -
}

main $@
