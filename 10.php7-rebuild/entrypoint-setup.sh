#!/usr/bin/env bash

rm -rf /root/.ssh
mkdir /root/.ssh
cp /mnt/ssh/* /root/.ssh/
chmod 700 /root/.ssh
chmod 600 /root/.ssh/*

ln -s /mnt/src/example1.co.jp /home/example1.co.jp
ln -s /mnt/src/example2.co.jp /home/example2.co.jp

/usr/local/bin/dns-regist.sh
