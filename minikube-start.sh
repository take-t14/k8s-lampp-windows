#!/bin/bash

echo $(service docker status | awk '{print $4}') #起動状態を表示
if test $(service docker status | awk '{print $4}') = 'not'; then #停止状態
    sudo /usr/sbin/service docker start #起動
fi

MINIKUBE=`minikube status 2>&1 | grep -e "Stopped" -e "Nonexistent"` #起動状態を表示
echo $MINIKUBE
if [ -n "$MINIKUBE" ]; then #停止状態
    minikube start --driver=docker --kubernetes-version=v1.22.1 --memory='4g' --cpus=4 #起動
fi
