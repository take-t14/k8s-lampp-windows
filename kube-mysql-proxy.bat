@echo off

kubectl config set-context docker-desktop --namespace=k8s-lampp-windows  
kubectl port-forward mysql-0 3306:3306

@echo on
