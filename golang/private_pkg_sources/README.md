# Настройка доступа `go get` к приватным репозиториям

## Содержимое

1. [Github/Gitlab доступ по OAuth Token](access_token.md)
2. [Github/Gitlab доступ по OAuth Token в Docker](access_token_docker.md)
3. [Github/Gitlab доступ по SSH](ssh.md)

## Необходимо информация

1. `GO111MODULE`

    Управляет запуском команды go в режиме с поддержкой модуля или в режиме GOPATH.

2. `GOPRIVATE`

    Список разделенных запятыми glob шаблонов (в синтаксисе Go path.Match) префиксов путей к модулям, которые следует считать частными.
