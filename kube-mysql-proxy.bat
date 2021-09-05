@echo off

kubectl config set-context minikube --namespace=k8s-lampp-windows  
kubectl port-forward mysql-0 3306:3306

@echo on
