#!/bin/bash

kubectl config set-context minikube --namespace=k8s-lampp-windows  

skaffold run

