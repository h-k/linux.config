#!/bin/sh
#set -x
set -e
[ -z "$1" ] && exit 1
url="$1"
path="$2"
[ -z "$path" ] && path="$(echo "$url" | sed 's/^.*//')"
svn_path="$url"
[ -n "$3" ] && svn_path="$3"
if [ ! -d "$path" ]
then
	first_rev="$(svn log -r 1:HEAD --stop-on-copy --limit 1 --xml "$url" | grep 'revision="[0-9]\+"' | head -n1 | sed 's/^.*revision="\([0-9]\+\)".*$/\1/')"
	git svn clone -r "$first_rev":HEAD "$url" "$path" || exit 1
fi
cd "$path"
#git checkout -b externals master || true
#git submodule init
# Get all externals
EXTERNALS_PATH="${EXTERNALS_PATH:-$HOME/gitsvn/externals}"
mkdir -p "$EXTERNALS_PATH"
svn propget -R svn:externals "$svn_path" | \
awk 'BEGIN {path=""}
{
	if (NF==4 && $2=="-")
	{path=$1;item1=$3;item2=$4;}
	else if (NF==2) {item1=$1;item2=$2;}
	else {item1="";item="";}
	if (item1!="" && item2!="") {
		if (item1 ~/^http:\/\//) {
			url=item1; loc=item2;
		} else if (item2 ~/^http:\/\//)
		{
			url=item2; loc=item1;
		} else { loc=""; url=""; }
		if (loc!="" && url!="") {
			if (path==".") print  loc " " url
			else print path "/" loc " " url
		}
	}
}' | sed "s#$svn_path/\?##" | \
while read ext_path ext_url ; do
	if [ -z "$ext_path" ] || [ -z "$ext_url" ] ; then continue ; fi
	ext_git_name="$(echo "$ext_path" | sed 's/^.*\/\([^\/]\+\)\/\?$/\1/')"
	while [ -d "$EXTERNALS_PATH/$ext_git_name" ]
	do
		pushd .
		cd  "$EXTERNALS_PATH/$ext_git_name"
		if [ "$( git svn info | grep "^URL: " | sed 's/^URL: //' )" != "$( echo "$ext_url" | sed 's/\/$//' )" ]
		then
			ext_git_name="${ext_git_name}_"
		else
			popd
			break;
		fi
		popd
	done
	if [ ! -d "$EXTERNALS_PATH/$ext_git_name" ]
	then
		first_rev="$(svn log -r 1:HEAD --stop-on-copy --limit 1 --xml "$ext_url" | grep 'revision="[0-9]\+"' | head -n1 | sed 's/^.*revision="\([0-9]\+\)".*$/\1/')"
		git svn clone -r "$first_rev":HEAD "$ext_url" "$EXTERNALS_PATH/$ext_git_name" || exit 1
	fi
#	git submodule add "$EXTERNALS_PATH/$ext_git_name" "$ext_path" || exit 1
done
#git commit -m"Added external repositories"
