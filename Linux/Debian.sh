#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"

usage(){
    cat<<EOF
Usage: $(basename $0) [mirror]

mirror:
    aliyun
    163
    tencent
EOF
    exit 1
}

rootID=0
if [ "$EUID" -ne "${rootID}" ];then
    echo "Need root privilege"
    exit 1
fi

urlAliyun="http://mirrors.aliyun.com/debian/"
url163="http://mirrors.163.com/debian/"
urlTencent="http://mirrors.cloud.tencent.com/debian"

mirror=${1}
case ${mirror} in
    aliyun)
        URL="${urlAliyun}"
        ;;
    163)
        URL="${url163}"
        ;;
    tencent)
        URL="${urlTencent}"
        ;;
    *)
        usage
        ;;
esac


srcList="/etc/apt/sources.list"

if [ ! -e "${srcList}" ];then
    echo "Cann't find file: \"${srcList}\""
    exit 1
fi

releaseFile="/etc/os-release"
if [ ! -e "${releaseFile}" ];then
    echo "No file: ${releaseFile} ,not debian ?"
    exit 1
fi

codename="$(perl -lne 'print if /VERSION=/' ${releaseFile}  | perl -lne 'print $1 if /[^(]+\((\w+)/')"
echo "codename: ${codename}"
# backup
mv "${srcList}" "${srcList}.bak"
cat>${srcList}<<EOF
deb ${URL} ${codename} main non-free contrib
deb ${URL} ${codename}-updates main non-free contrib
deb ${URL} ${codename}/updates main
deb ${URL} ${codename}-backports main non-free contrib

deb-src ${URL} ${codename} main non-free contrib
deb-src ${URL} ${codename}-updates main non-free contrib
deb-src ${URL} ${codename}/updates main
deb-src ${URL} ${codename}-backports main non-free contrib
EOF

echo "Done."
