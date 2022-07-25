# Приложение для тестирования деплоя в k8s

1. Зарегестрируйтесь на [DockerHub](https://hub.docker.com/)

2. Создайте репозиторий.

Пример: https://hub.docker.com/r/altheone/k8s_test_app1

4. Создайте токен

5. Добавьте авторизационный токен

```shell
docker login
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
