#!/bin/bash

kubectl config set-context docker-for-desktop --namespace=k8s-lapp-windows  

skaffold run

