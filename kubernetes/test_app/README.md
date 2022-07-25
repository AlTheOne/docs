# Приложение для тестирования деплоя в k8s

1. Зарегестрируйтесь на [DockerHub](https://hub.docker.com/)

2. Создайте репозиторий.

Пример: https://hub.docker.com/r/altheone/k8s_test_app1

4. Создайте токен

5. Добавьте авторизационный токен

```shell
docker login -u <DOCKER_HUB_LOGIN>
```

* Команда запросит пароль. В качестве пароля введите полученный токен.

5. Создайте образ
```shell
docker build -t <DOCKER_HUB_LOGIN>/<REPO_NAME> .
```

- `<DOCKER_HUB_LOGIN>` - Логин на ресурсе DockerHub.
- `<REPO_NAME>` - Название репозитория на ресурсе DockerHub.

Например: `docker build -t altheone/k8s_test_app1 .`

6. Проверьте работоспособность приложения.
```shell
docker run -p 9980:80 <DOCKER_HUB_LOGIN>/<REPO_NAME>
```

Например: `docker run -p 9980:80 altheone/k8s_test_app1`

Приложение должно быть доступно по адресу: `http://localhost:9980`

7. Отправьте образ в DockerHub
```shell
docker push <DOCKER_HUB_LOGIN>/<REPO_NAME>
```

Например: `docker push altheone/k8s_test_app1`


Развёртываем приложение в k8s
---

Условия:

| Сущность                       | Host                   | Port   | Comments                                                          |
|--------------------------------|------------------------|--------|-------------------------------------------------------------------|
| Приложение                     | `0.0.0.0`              | `80`   |                                                                   |
| Docker контейнер с приложением | -                      | `80`   | Определён с помощью `EXPOSE 80` в Dockerfile                      |
| [k8s] Namespace `test-app1-ns` | -                      | -      | Для того, чтобы все элементы были в одном окружении и доступности |
| [k8s] Deployment               | Выделяется при запуске | `80`   | Порт определён по EXPOSE 80 в Dockerfile                          |
| [k8s] Service                  | Выделяется при запуске | `9980` | Порт определяем в YAML файле                                      |

---

1. Создать окружение для приложения с названием: `test-app1-ns`

2. Создать Deployment для приложения. \
Название файла: `test_app1_deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app1-pod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-app1-pod
  template:
    metadata:
      labels:
        app: test-app1-pod
    spec:
      containers:
      - name: test-app1-pod
        image: altheone/k8s_test_app1
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        resources:
          limits:
            cpu: 200m
            memory: 500Mi
          requests:
            cpu: 100m
            memory: 500Mi
```

- `test-app1-pod` - название pod'а
- `containerPort: 80` - писанина для человека, что приложение работает на 80 порту (именно в Dockerfile EXPOSE 80)

Внутри кластера можно проверить работоспособность:
```
curl <Pod IP>:80
```

Запустить:
```
sudo kubectl create -f test_app1_deployment.yaml -n test-app1-ns
```

3. Создать Service.\
Название файла: `test_app1_service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: test-app1-service
spec:
  ports:
    - protocol: TCP
      port: 9980
      targetPort: 80
  selector:
    app: test-app1-pod
```

- `name: test-app1-service` - Название сервиса
- `app: test-app1-pod` - Селектор указывает на приложение на порт которого будет отправляться трафик
- `port: 9980` - Сервис слушает порт 9980
- `targetPort: 80` - Сервис переправляет трафик 9980->80

Запустить:
```
sudo kubectl create -f test_app1_service.yaml -n test-app1-ns
```

Проверка доступа к Service:
```shell
curl <CLUSTER_IP>:9980
```

- `<CLUSTER_IP>` - на котором запущен сервис

4. После успешного создания Service в k8s появится Endpoint предоставляющий путь к Pod
```shell
curl <CLUSTER_IP>:9980
```

---

Полезные статьи
- https://www.kryukov.biz/kubernetes/set-kubernetes-teoriya/services/
