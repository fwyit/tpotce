#!/usr/bin/env bash
#author      : Jam < liujianhncn@gmail.com >
#version     : 1.0
#description : 本脚本主要用来使用阿里云镜像加速国内下载



test -z "$(which git 2>/dev/null)" && apt-get update && apt install -y git docker-compose
MIRROR=registry-vpc.cn-beijing.aliyuncs.com
curl -m 2 https://$MIRROR/v2/ || MIRROR=registry.cn-beijing.aliyuncs.com
if test -z "$(which docker 2>/dev/null)"; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo "deb https://mirrors.aliyuncs.com/docker-ce/linux/debian/ `lsb_release -cs` stable" > /etc/apt/sources.list.d/docker.list
    apt-get update && apt-get install -y docker-ce
fi

repo=$MIRROR/fwy/tpot
docker pull $repo:src
docker run -d --name tpot $repo:src tail -f /etc/hosts
if test ! -d /opt/tpot; then
    mkdir -p /opt/tpot
    docker cp tpot:/src.tgz /tmp/
    tar -zxf /tmp/src.tgz -C /opt/tpot
    docker stop tpot
    docker rm tpot
fi
#test ! -d /opt/tpot && git clone -b dev https://github.com/fwyit/tpotce /opt/tpot
sed -i -e "s@dtagdevsec/\(.*\):.*\"@$MIRROR/fwy/tpot:\1\"@g" /opt/tpot/etc/compose/*

bash /opt/tpot/iso/installer/install.sh "$@"
