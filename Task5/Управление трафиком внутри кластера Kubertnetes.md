# Управление трафиком внутри кластера Kubernetes

## Установить kind

Предварительно вырубить докер куб - https://kind.sigs.k8s.io/docs/user/quick-start/#installation

```bash
# Создаем новый кластер
kind create cluster --config kind-calico.yaml
```

## Установить cilium

https://github.com/cilium/cilium-cli

```bash
# Добавить в текущий кластер
cilium install

# Включить UI для просмотра сети
cilium hubble enable --ui
cilium hubble ui
```

## Проверяем что cilium работает

```bash
kubectl get pods -l k8s-app=cilium -A
```

## Даем права на выполнение

```bash
chmod +x main.sh
```

## Запускаем скрипт

```bash
./main.sh
```

## Проверка созданных меток

```bash
kubectl get pods --show-labels -n apps
```

## Проверка сетевых политик

```bash
# Успешно проходит трафик
kubectl exec -n apps front-end-app -- curl back-end-api-app
kubectl exec -n apps admin-front-end-app -- curl admin-back-end-api-app
# Трафик не проходит
kubectl exec -n apps front-end-app -- curl admin-back-end-api-app
kubectl exec -n apps admin-front-end-app -- curl back-end-api-app
```
