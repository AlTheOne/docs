# Настройка доступа к Github/Gitlab с помощью Token


## 1. Создать personal access token

Необходимо создать токен на уровне репозитория/проекта или выше.

- [Github Token](https://github.com/settings/tokens)
- [Gitlab Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token)

Токен должен иметь доступ: `read_repository`


## 2. Настройка `~/.netrc`

Создайте файл `.netrc` если он не существует:

```sh
touch ~/.netrc
```

Дайте права только владельцу:
```sh
chmod 600 ~/.netrc
```

Указать в содержимом файла:
```
machine privategitlab.company.com login <USERNAME> password <ACCESS_TOKEN>
```

где:
- `<USERNAME>` -- имя пользователя GitHub/GitLab
- `<ACCESS_TOKEN>` -- токен, полученный в п.1


## Установка пакета

```sh
export GO111MODULE=on
export GOPRIVATE=privategitlab.company.com

go get -u privategitlab.company.com/backend/private-repo
```

В случае GitHub можно указать:
`export GOPRIVATE=github.com`

В примере я временно переопределю переменные окружения GO.

Вы же можете заменить их на постоянной основе:
```sh
go env -w GO111MODULE=on
go env -w GOPRIVATE=github.com

go env
```
