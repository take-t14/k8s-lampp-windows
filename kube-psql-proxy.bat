@echo off

kubectl config set-context docker-for-desktop --namespace=k8s-lapp-windows  
kubectl port-forward postgresql-0 5432:5432

@echo on
