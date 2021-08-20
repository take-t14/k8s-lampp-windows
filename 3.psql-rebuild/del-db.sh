#!/bin/bash

kubectl config set-context docker-desktop --namespace=k8s-lampp-windows  

kubectl delete -f k8s-db-sv.yaml

if [ ! -e /mnt/z ] ; then
    mkdir /mnt/z
fi

mountpoint -q /mnt/z
if [ $? -eq 0 ] ; then
    umount /mnt/z
fi
mount -t drvfs z: /mnt/z

if [ -e /mnt/z/version-pack-data/community/k8s/k8s-lampp-windows/1.db-disk/storage/postgresql ]; then
    rm -rf /mnt/z/version-pack-data/community/k8s/k8s-lampp-windows/1.db-disk/storage/postgresql
fi
