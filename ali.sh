#!/usr/bin/env bash
#author      : Jam < liujianhncn@gmail.com >
#version     : 1.0
#description : 本脚本主要用来使用阿里云镜像加速国内下载

MIRROR=registry-vpc.cn-beijing.aliyuncs.com
curl -m 2 https://$MIRROR/v2/ || MIRROR=registry.cn-beijing.aliyuncs.com

cp /etc/apt/sources.list /etc/apt/sources.list.`date +%m%d%H%M`.bak
test -z "$(which git 2>/dev/null)" && apt-get update && apt-get install -y git
test -z "$(which docker-compose 2>/dev/null)" && apt-get install -y docker-compose apt-transport-https
if test -z "$(which docker 2>/dev/null)"; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo "deb https://mirrors.aliyun.com/docker-ce/linux/debian/ `lsb_release -cs` stable" > /etc/apt/sources.list.d/docker.list
    apt-get update && apt-get install -y && apt-get install -y docker-ce
fi

repo=$MIRROR/fwy/tpot
docker pull $repo:src
test -z "$(docker ps | grep tpot)" || docker run -d --name tpot $repo:src tail -f /etc/hosts
sleep 4
if test ! -d /opt/tpot || test `ls /opt/tpot | wc -l` -eq 0; then
    mkdir -p /opt/tpot
    docker cp tpot:/src.tgz /tmp/
    tar -zxf /tmp/src.tgz -C /opt/tpot
    docker stop tpot
    docker rm tpot
else
    ( cd /opt/tpot && git pull origin `git branch | grep '*' | awk '{print $NF}'` )
fi
#test ! -d /opt/tpot && git clone -b dev https://github.com/fwyit/tpotce /opt/tpot
sed -i -e "s@dtagdevsec/\(.*\):.*\"@$MIRROR/fwy/tpot:\1\"@g" /opt/tpot/etc/compose/*

tee /etc/apt-fast.conf <<EOF
MIRRORS=('http://mirrors.cloud.aliyuncs.com/debian/,https://mirrors.aliyun.com/debian/')
EOF

echo "当前apt-fast配置:"
cat /etc/apt-fast.conf

install=/opt/tpot/iso/installer/install.sh
sed -i 's/deb.debian.org/mirrors.cloud.aliyuncs.com/g' $install
bash $install --type=${TYPE:=user}
