@echo off

kubectl config set-context docker-for-desktop --namespace=k8s-lampp-windows  
kubectl port-forward mysql-0 3306:3306

@echo on