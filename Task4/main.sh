#!/bin/bash

# Создание namespace-а
kubectl create namespace apps

# Создание приватных ключей
mkdir keys
openssl genrsa -out ./keys/developer-keka.key 2048
openssl genrsa -out ./keys/devops-peka.key 2048
openssl genrsa -out ./keys/security-keka-peka.key 2048

# Создание CSR (Certificate Signing Request), CN (Common Name), O (Organization)
# https://www.msys2.org/docs/filesystem-paths/#automatic-unix-windows-path-conversion
mkdir csr
MSYS2_ARG_CONV_EXCL='/C' openssl req -new -key ./keys/developer-keka.key -out ./csr/developer-keka.csr -subj "/CN=developer-keka/O=developers"
MSYS2_ARG_CONV_EXCL='/C' openssl req -new -key ./keys/devops-peka.key -out ./csr/devops-peka.csr -subj "/CN=devops-peka/O=devops"
MSYS2_ARG_CONV_EXCL='/C' openssl req -new -key ./keys/security-keka-peka.key -out ./csr/security-keka-peka.csr -subj "/CN=security-keka-peka/O=security"

# Подписание сертификатов через API Kubernetes
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: developer-keka-csr
spec:
  request: $(cat ./csr/developer-keka.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: devops-peka-csr
spec:
  request: $(cat ./csr/devops-peka.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: security-keka-peka-csr
spec:
  request: $(cat ./csr/security-keka-peka.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Получение сертификатов
kubectl certificate approve developer-keka-csr
kubectl certificate approve devops-peka-csr
kubectl certificate approve security-keka-peka-csr

mkdir certs
kubectl get csr developer-keka-csr -o jsonpath='{.status.certificate}' | base64 -d > ./certs/developer-keka.crt
kubectl get csr devops-peka-csr -o jsonpath='{.status.certificate}' | base64 -d > ./certs/devops-peka.crt
kubectl get csr security-keka-peka-csr -o jsonpath='{.status.certificate}' | base64 -d > ./certs/security-keka-peka.crt

# Применяем конфиги ролей и привязки
kubectl apply -f ./roles/developer.yaml
kubectl apply -f ./roles/devops.yaml
kubectl apply -f ./roles/security.yaml
kubectl apply -f ./roles/viewer.yaml

kubectl apply -f ./bindings/developer.yaml
kubectl apply -f ./bindings/devops.yaml
kubectl apply -f ./bindings/security.yaml

# Привязываем сертификаты и ключи к пользователям
kubectl config set-credentials developer-keka \
  --client-certificate=./certs/developer-keka.crt \
  --client-key=./keys/developer-keka.key \
  --embed-certs=true
kubectl config set-credentials devops-peka \
  --client-certificate=./certs/devops-peka.crt \
  --client-key=./keys/devops-peka.key \
  --embed-certs=true
kubectl config set-credentials security-keka-peka \
  --client-certificate=./certs/security-keka-peka.crt \
  --client-key=./keys/security-keka-peka.key \
  --embed-certs=true

# Настройка пользователей
kubectl config set-context developer-context \
  --cluster=docker-desktop \
  --namespace=apps \
  --user=developer-keka
kubectl config set-context devops-context \
  --cluster=docker-desktop \
  --user=devops-peka
kubectl config set-context security-context \
  --cluster=docker-desktop \
  --user=security-keka-peka
