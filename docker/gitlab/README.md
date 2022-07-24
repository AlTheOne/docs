# Установка Gitlab + Runner в docker-compose

## Установка

1. Создаём рабочую директорию (например, `gitlab`)
2. Создаём переменную окружения, которая будет содержать путь к рабочей директории

```
> export GITLAB_HOME=/home/altheone/gitlab
```

4. Создаём файл `docker-compose.yml`

```docker-compose.yml
version: '3.7'
services:
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: 'localhost'
    container_name: gitlab-ce
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://localhost'
    ports:
      - '8080:80'
      - '8443:443'
      - '8022:22'
    volumes:
      - '$GITLAB_HOME/config:/etc/gitlab'
      - '$GITLAB_HOME/logs:/var/log/gitlab'
      - '$GITLAB_HOME/data:/var/opt/gitlab'
    networks:
      - gitlab
  gitlab-runner:
    image: gitlab/gitlab-runner:alpine
    container_name: gitlab-runner    
    restart: always
    depends_on:
      - web
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - '$GITLAB_HOME/gitlab-runner:/etc/gitlab-runner'
    networks:
      - gitlab

networks:
  gitlab:
    name: gitlab-network
```

- `hostname: 'localhost'` - Имя хоста внутри контейнера
- `external_url 'http://localhost'` - При настройке на сервере указать домен или публичный IP

5. Запуск
```
> docker-compose up -d
```

6. Получаем пароль пользователя `root`
```
> docker exec -it gitlab-ce grep 'Password:' /etc/gitlab/initial_root_password
```

7. Изменить пароль от пользователя `root`. 

8. В настройках админа поменять URL для клонирования репозитория: \
URL: `http://localhost:8080/admin/application_settings/general`


## Настройка Gitlab Runner
1. Получить токен для Runner'а \
URL: `http://localhost:8080/admin/runners`
2. Запустить процедуру создания Runner'а \
```
> docker exec -it gitlab-runner gitlab-runner register --url "http://gitlab-ce" --clone-url "http://gitlab-ce"
```

2.1. Указать ссылку на GitLab: Нажать Enter для выбора по умолчанию \
2.2. Указать регистрационный токен: Ввести скопированный токен \
2.3. Указать описание: Написать имя runner'а. Например, `docker-runner` \
2.4. Указать теги: Пропустить (если будут указаны теги, тогда у коммитов должны быть теги, чтобы раннер среагировал. \
2.5. Указать исполнителя: Ввести `docker` \
2.6. Указать образ докера по умолчанию: например, `python:3.9`

Runner создан.

3. Необходимо подключить runner к сети gitlab'а.
```
>  sudo nano gitlab/gitlab-runner/config.toml
```

Указать `network_mode = "gitlab-network""`

E.g.
```
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "global"
  url = "http://gitlab-ce"
  token = "d3rS_QAUUqD8UMe_TAta"
  executor = "docker"
  clone_url = "http://gitlab-ce"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "alpine"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
    network_mode = "gitlab-network"
```
