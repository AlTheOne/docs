# Настройка Celery на сервере

Создаём нового пользователя с именем `celery`:

`sudo useradd celery -d /home/celery -b /bin/bash`

Даём права на директории:
```
sudo mkdir /var/log/celery
sudo chown -R celery:celery /var/log/celery
sudo chmod -R 755 /var/log/celery

sudo mkdir /var/run/celery
sudo chown -R celery:celery /var/run/celery
sudo chmod -R 755 /var/run/celery
```

# Создание службы.

Для проверки в режиме разработки достаточно использовать команду:

`celery -A projectile worker --loglevel=DEBUG`

из директории проекта.

Однако, для прода необходимо создавать службу.

Создаём файл с переменными `/etc/conf.d/celery`:
```
# Name of nodes to start
# here we have a single node
CELERYD_NODES="w1"
# or we could have three nodes:
#CELERYD_NODES="w1 w2 w3"

# Absolute or relative path to the 'celery' command:
CELERY_BIN="/home/django/env/bin/celery"

# App instance to use
# comment out this line if you don't use an app
CELERY_APP="projectile"

# How to call manage.py
CELERYD_MULTI="multi"

# Extra command-line arguments to the worker
CELERYD_OPTS="--time-limit=300 --concurrency=8"

# - %n will be replaced with the first part of the nodename.
# - %I will be replaced with the current child process index
#   and is important when using the prefork pool to avoid race conditions.
CELERYD_PID_FILE="/var/run/celery/%n.pid"
CELERYD_LOG_FILE="/var/log/celery/%n%I.log"
CELERYD_LOG_LEVEL="INFO"
```

Создаём службу `/etc/systemd/system/celery.service`:
```
[Unit]
Description=Celery Service
After=network.target

[Service]
Type=forking
User=celery
Group=celery
EnvironmentFile=/etc/conf.d/celery
WorkingDirectory=/home/django/project/projectile
ExecStart=/bin/sh -c '${CELERY_BIN} multi start ${CELERYD_NODES} \
  -A ${CELERY_APP} --pidfile=${CELERYD_PID_FILE} \
  --logfile=${CELERYD_LOG_FILE} --loglevel=${CELERYD_LOG_LEVEL} ${CELERYD_OPTS}'
ExecStop=/bin/sh -c '${CELERY_BIN} multi stopwait ${CELERYD_NODES} \
  --pidfile=${CELERYD_PID_FILE}'
ExecReload=/bin/sh -c '${CELERY_BIN} multi restart ${CELERYD_NODES} \
  -A ${CELERY_APP} --pidfile=${CELERYD_PID_FILE} \
  --logfile=${CELERYD_LOG_FILE} --loglevel=${CELERYD_LOG_LEVEL} ${CELERYD_OPTS}'

[Install]
WantedBy=multi-user.target
```

Далее перегружаем демон systemd: `sudo systemctl daemon-reload`

При каждом изменении
`/etc/conf.d/celery` или
`/etc/systemd/system/celery.service` необходимо выполнять перезагрузку демона systemd:

`sudo systemctl daemon-reload`

---

Запуск службы:

`sudo systemctl start celery`

Статус службы:

`sudo systemctl status celery`

Перезапуск службы:

`sudo systemctl restart celery`

Остановка службы:

`sudo systemctl stop celery`
