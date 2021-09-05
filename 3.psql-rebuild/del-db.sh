#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)

kubectl config set-context minikube --namespace=k8s-lampp-windows  

kubectl delete -f k8s-sv.yaml

echo "DBデータを削除するので管理者パスワードを入力して下さい"
sudo ./del-db-data.sh