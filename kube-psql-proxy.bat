@echo off

kubectl config set-context docker-desktop --namespace=k8s-lampp-windows  
kubectl port-forward postgresql-0 5432:5432

@echo on
