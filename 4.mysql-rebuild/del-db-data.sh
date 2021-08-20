#!/bin/bash

if [ ! -e /mnt/z ] ; then
    mkdir /mnt/z
fi

mountpoint -q /mnt/z
if [ $? -eq 0 ] ; then
    umount /mnt/z
fi
mount -t drvfs z: /mnt/z

if [ -e /mnt/z/version-pack-data/community/k8s/k8s-lampp-windows/1.db-disk/storage/mysql ]; then
    rm -rf /mnt/z/version-pack-data/community/k8s/k8s-lampp-windows/1.db-disk/storage/mysql
fi