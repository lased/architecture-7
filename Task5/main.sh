#!/bin/bash

# Создание namespace-а
kubectl create namespace apps

# Создание меток
kubectl run front-end-app -n apps --image=nginx --labels role=front-end --expose --port=80
kubectl run back-end-api-app -n apps --image=nginx --labels role=back-end-api --expose --port=80
kubectl run admin-front-end-app -n apps --image=nginx --labels role=admin-front-end --expose --port=80
kubectl run admin-back-end-api-app -n apps --image=nginx --labels role=admin-back-end-api --expose --port=80

# Деплоим сетевую политику
kubectl apply -f networkpolicy.yaml