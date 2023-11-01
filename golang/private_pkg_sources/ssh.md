# Настройка доступа к Github/Gitlab по SSH


## 1. Создать файл `~/.ssh/config`

```sh
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```


## 2. Конфигурации

Указать в файле `~/.ssh/config`
```
Host privategitlab.company.com
  Hostname privategitlab.company.com
  User <USERNAME>
  IdentityFile ~/.ssh/id_rsa
```

где:
- `<USERNAME>` -- имя пользователя GitHub/GitLab

**Отступы в приведенном выше файле важны!**


## 3. Добавить свой `~/.ssh/id_rsa.pub`

В аккуант или репозиторий GitHub/GitLab.

## Установка пакета

```sh
export GO111MODULE=on
export GOPRIVATE=privategitlab.company.com

go get -u privategitlab.company.com/backend/private-repo
```

В случае GitHub можно указать:
`export GOPRIVATE=github.com`

В примере я временно переопределю переменные окружения GO.

Вы же можете заменять их на постоянной основе:
```sh
go env -w GO111MODULE=on
go env -w GOPRIVATE=github.com

go env
```
