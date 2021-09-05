#!/bin/bash

MINIKUBE=`minikube status 2>&1 | grep -e "Stopped" -e "Nonexistent"` #起動状態を表示
echo $MINIKUBE
if [ -z "$MINIKUBE" ]; then #起動状態
    echo "minikube stoping..."
    minikube stop #終了
fi

echo $(service docker status | awk '{print $4}') #起動状態を表示
if test $(service docker status | awk '{print $4}') != 'not'; then #起動状態
    echo "docker stopping..."
    sudo /usr/sbin/service docker stop #終了
fi
