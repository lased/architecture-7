# Защита доступа к кластеру Kubernetes

## Роли и их полномочия при работе с Kubernetes

| Роль              | Ключевое слово для роли | Полномочия                                                                                           |
| ----------------- | ----------------------- | ---------------------------------------------------------------------------------------------------- |
| Viewer            | viewer                  | - просмотр данных                                                                                    |
| Разработчик       | developer               | - создание, изменение и удаление приложений<br>- управление конфигурациями<br>- управление секретами |
| DevOps-инженер    | devops-engineer         | - автоматизация CI/CD<br>- управление кластером Kubernetes<br>- управление секретами<br>- мониторинг |
| Security Engineer | security                | - полный доступ для аудита и проверки безопасности кластера                                          |

## Даем права на выполнение

```bash
chmod +x main.sh
```

## Запускаем скрипт

```bash
./main.sh
```

## Проверяем созданные CSR (Certificate Signing Request)

```bash
kubectl get csr
```

## Проверяем созданные роли

```bash
kubectl get clusterroles | grep -E "devops|security|viewer"
kubectl get roles -n apps
```

## Проверяем созданные привязки

```bash
kubectl get clusterrolebindings  | grep -E "devops|security|viewer"
kubectl get rolebindings -n apps
```

## Проверяем права доступа

Дефолтный контекст - `docker-desktop`

```bash
# Используем контекст разработчика
kubectl config use-context developer-context
# Тут ошибка
kubectl run nginx --image=nginx -n default
# Тут успех
kubectl run nginx --image=nginx -n apps
```
