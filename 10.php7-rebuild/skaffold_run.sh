#!/bin/bash

kubectl config set-context docker-desktop --namespace=k8s-lampp-windows  

skaffold run

