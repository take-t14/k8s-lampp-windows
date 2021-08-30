#!/usr/bin/env bash

rm -rf /root/.ssh
mkdir /root/.ssh
cp /mnt/ssh/* /root/.ssh/
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*

/usr/local/bin/dns-regist.sh
