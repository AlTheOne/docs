# Установка приватных Golang пакетов в Docker через SSH

## Dockerfile

```Dockerfile
FROM golang:1.21.3-alpine3.17 as builder

ARG GOPRIVATE
ARG SSH_ID_RSA
ARG SSH_CONFIG

# Install needed lib
RUN apk add --update --no-cache git openssh

# Git: change default method: https -> ssh
RUN git config --global url.ssh://git@github.com.insteadOf https://github.com

# Go ENV
RUN go env -w GO111MODULE=on
RUN go env -w GOPRIVATE=$GOPRIVATE

# SSH

# SSH: Prepare dir
RUN mkdir -p /root/.ssh

# SSH: Save ID_RSA for arg variable
RUN echo "$SSH_ID_RSA" > /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# SSH: Save ssh config file for arg variable
RUN echo "$SSH_CONFIG" > /root/.ssh/config
RUN chmod 600 /root/.ssh/config

# SSH: Create known_hosts
RUN touch /root/.ssh/known_hosts

# SSH: Add git providers to known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN ssh-keyscan gitlab.com >> /root/.ssh/known_hosts

RUN go version

WORKDIR /app

COPY . .
COPY go.mod .

RUN go build -o /app/api /app/cmd/api/
```


## Описание аргументов

`GOPRIVATE` - список разделенных запятыми glob шаблонов (в синтаксисе Go path.Match) префиксов путей к модулям, которые следует считать частными.

Например,
```
GOPRIVATE=github.com/private-org/private-repo
GOPRIVATE=*.gitlab.com
GOPRIVATE=bitbucket.org/private-org/*

GOPRIVATE=github.com/private-org/private-repo,*.gitlab.com/,bitbucket.org/private-org/*
```

`SSH_ID_RSA` - закрытый SSH ключ.

`SSH_CONFIG` - файл конфигурации ssh.

Пример содержимого:
```
Host github.com
  Hostname github.com
  User <USERNAME>
  IdentityFile /root/.ssh/id_rsa
```


## Команда сборки образа
```sh
docker buildx build . \
	-t myimage \
	--build-arg GOPRIVATE="github.com/private-org/*" \
	--build-arg SSH_ID_RSA="$(cat ~/.ssh/id_rsa)" \
	--build-arg SSH_CONFIG="Host github.com\n\tHostname github.com\n\tUser AlTheOne\n\tIdentityFile /root/.ssh/id_rsa"
```
