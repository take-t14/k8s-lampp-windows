#!/bin/bash

if [ ! -e /mnt/k8s ] ; then
    mkdir /mnt/k8s
fi

mountpoint -q /mnt/k8s
if [ $? -eq 0 ] ; then
    umount /mnt/k8s
fi
mount --bind /var/lib/docker/volumes/minikube/_data/lib/k8s /mnt/k8s

if [ -e /mnt/k8s/k8s-lampp-windows/1.db-disk/storage/postgresql ]; then
    rm -rf /mnt/k8s/k8s-lampp-windows/1.db-disk/storage/postgresql
fi
