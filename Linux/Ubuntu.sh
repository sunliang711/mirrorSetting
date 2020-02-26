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

urlAliyun="http://mirrors.aliyun.com/ubuntu/"
url163="http://mirrors.163.com/ubuntu/"
urlTencent="http://mirrors.cloud.tencent.com/ubuntu"

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

##NOTE ubuntu 16,18,20的 腾讯云镜像设置后update失败
##TODO: 修复以上问题

srcList="/etc/apt/sources.list"

if [ ! -e "${srcList}" ];then
    echo "Cann't find file: \"${srcList}\""
    exit 1
fi

codename="$(grep -oP '(?<=DISTRIB_CODENAME=)[^=]+' /etc/lsb-release)"

# backup
mv "${srcList}" "${srcList}.bak"

cat>"${srcList}"<<EOF
deb ${URL} ${codename} main restricted universe multiverse
deb ${URL} ${codename}-security main restricted universe multiverse
deb ${URL} ${codename}-backports main restricted universe multiverse
deb ${URL} ${codename}-updates main restricted universe multiverse
## Not recommended
# deb ${URL} ${codename}-proposed main restricted universe multiverse

deb-src ${URL} ${codename} main restricted universe multiverse
deb-src ${URL} ${codename}-security main restricted universe multiverse
deb-src ${URL} ${codename}-updates main restricted universe multiverse
deb-src ${URL} ${codename}-backports main restricted universe multiverse
## Not recommended
# deb-src ${URL} ${codename}-proposed main restricted universe multiverse
EOF

echo "Done."