#!/usr/bin/env bash
#author      : Jam < liujianhncn@gmail.com >
#version     : 1.0
#description : 本脚本主要用来使用阿里云镜像加速国内下载


cd iso/installer

test -z "$(which git 2>/dev/null)" && apt-get update && apt install -y git
test ! -d /opt/tpot && git clone -b dev https://github.com/fwyit/tpotce /opt/tpot
MIRROR=registry-vpc.cn-beijing.aliyuncs.com
curl -m 2 https://$MIRROR/v2/ || MIRROR=registry.cn-beijing.aliyuncs.com
sed -i -e "s@dtagdevsec/\(.*\):.*\"@$MIRROR/fwy/tpot:\1\"@g" /opt/tpot/etc/compose/*

./install.sh "$@"
