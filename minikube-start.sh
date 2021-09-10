#!/bin/bash

echo $(service docker status | awk '{print $4}') #起動状態を表示
if test $(service docker status | awk '{print $4}') = 'not'; then #停止状態
    sudo /usr/sbin/service docker start #起動
fi

MINIKUBE=`minikube status 2>&1 | grep -e "Stopped" -e "Nonexistent"` #起動状態を表示
echo $MINIKUBE
if [ -n "$MINIKUBE" ]; then #停止状態
    minikube start --driver=docker --kubernetes-version=v1.22.1 --memory='3g' --cpus=2 #起動
fi

if [ ! -e /mnt/k8s ] ; then
        sudo mkdir /mnt/k8s
fi
mountpoint -q /mnt/k8s
if [ ! $? -eq 0 ] ; then
    sudo mount --bind /var/lib/docker/volumes/minikube/_data/lib/k8s /mnt/k8s
fi

HOSTS=`minikube ssh "cat /etc/hosts" | grep host.docker.internal`
echo $HOSTS
export winhost=$(cat /etc/hosts | grep host.docker.internal | awk '{ print $1 }')
if [ -z "$HOSTS" ]; then
    minikube ssh "sudo su - -c 'echo \"$winhost host.docker.internal\" >> /etc/hosts'"
else
    minikube ssh "sudo su - -c 'cp /etc/hosts /etc/hosts_back; sed -i \"s/^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\} host\.docker\.internal$/$winhost host.docker.internal/\" /etc/hosts_back'"
    minikube ssh "sudo su - -c 'cp /etc/hosts_back /etc/hosts'"
fi
