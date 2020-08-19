# RabbitMQ

Установка и настройка брокера сообщений RabbitMQ.

# Установка

Установить Erlang:
```
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt update
sudo apt install erlang erlang-nox
```

Установить RabbitMQ Server:
```
echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo apt update
sudo apt install rabbitmq-serve
```

# Управление службой

Запуск службы:<br/>
`service rabbitmq-server start`

Остновка службы:<br/>
`service rabbitmq-server stop`

Перезапуск службы:<br/>
`service rabbitmq-server restart`

Проверка статуса:<br/>
`service rabbitmq-server status`

Старт:<br/>
`sudo rabbitmqctl start`

Стоп:<br/>
`sudo rabbitmqctl stop`


# Пользователи

Создание:<br/>
`sudo rabbitmqctl add_user <username> <password>`

Измение пароля:<br/>
`sudo rabbitmqctl change_password cinder <new_password>`

Сделать администратором:<br/>
`sudo rabbitmqctl set_user_tags <username> administrator`

Назначение привелегий:<br/>
`sudo rabbitmqctl set_permissions -p / <username> ".*" ".*" ".*"`

Списока привелегий:<br/>
`sudo rabbitmqctl list_permissions`