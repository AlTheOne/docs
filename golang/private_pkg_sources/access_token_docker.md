# Установка приватных Golang пакетов в Docker через OAuth Token

## Dockerfile

```Dockerfile
FROM golang:1.21.3-alpine3.17 as builder

ARG GOPRIVATE
ARG GIT_TOKEN

# Install needed lib
RUN apk add --update --no-cache git

# GIT
ENV GIT_TOKEN=$GIT_TOKEN
RUN git config --global url."https://${GIT_TOKEN}:x-oauth-basic@github.com".insteadOf https://github.com

# Go ENV
RUN go env -w GO111MODULE=on
RUN go env -w GOPRIVATE=$GOPRIVATE

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

`GIT_TOKEN` - токен.


## Команда сборки образа
```sh
docker buildx build . \
	-t myimage \
	--build-arg GOPRIVATE="github.com/private-org/*" \
	--build-arg GIT_TOKEN="<SOME_TOKEN>"
```
