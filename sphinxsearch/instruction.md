# Django + PostgreSQL + Sphinx (search)
Небольшая инструкция, чтобы подружить Django, Слона и Сфинкса, с целью сделать поиск на сайте.

# Стек
- Python 3.8 [ https://www.python.org/ ]
- Django 3.0 [ https://www.djangoproject.com/ ]
- PostgreSQL 12 [ https://www.postgresql.org/ ]
- Sphinx 3.1.1 [ http://sphinxsearch.com/ ]

# Настройка PostgreSQL
Необходимо, чтобы была установлена и настроена СУБД.

# Настройка Sphinx

Скачиваем дистрибутив Sphinx v3.1.1:
http://sphinxsearch.com/downloads/current/

Создадим директорию `sphinx` в файловой системе и перейдём в неё:
```
mkdir sphinx
cd sphinx
```

Создадим директорию `src` и распакуем в неё дистрибутив Sphinx:
```
mkdir src
tar xvzf /home/user/Download/sphinx-3.3.1-b72d67b-linux-amd64.tar.gz /home/user/sphinx/src/
```

Создадим папку `env-pg`:
```
mkdir env-pg
```

Создадим в папке `env-pg` конфигурационный файл `sphinx-pg.conf` со следующим содержимым:
```
# Название индекса соответствует названию таблицы в БД
index sphinx___news_news
{
    type = rt

    # Путь по которому будут сохранены файлы индекса для таблицы.
    # ВНИМАНИЕ! Папка news должна быть создана, иначе будет ошибка.
    path = /home/user/sphinx/env-pg/news/

    # Столбцы, определённые в модели (по ним будем искать)
    rt_field = title
    rt_field = content
    stored_fields = title, content

    # Следует ли определять и индексировать границы предложений и абзацев.
    # Необязательно, по умолчанию - 0.
    index_sp = 1

    # Удалять ли разметку HTML из входящих полнотекстовых данных.
    # Необязательно, по умолчанию - 0.
    # Известные значения: 0 (отключить удаление) и 1 (включить удаление). 
    html_strip = 1
}

# Название индекса соответствует названию таблицы в БД
index sphinx___blog_article
{
    type = rt

    # Путь по которому будут сохранены файлы индекса для таблицы.
    # ВНИМАНИЕ! Папка articles должна быть создана, иначе будет ошибка.
    path = /home/user/sphinx/env-pg/articles/

    # Столбцы, определённые в модели (по ним будем искать)
    rt_field = title
    rt_field = content
    stored_fields = title, content

    # Следует ли определять и индексировать границы предложений и абзацев.
    # Необязательно, по умолчанию - 0.
    index_sp = 1

    # Удалять ли разметку HTML из входящих полнотекстовых данных.
    # Необязательно, по умолчанию - 0.
    # Известные значения: 0 (отключить удаление) и 1 (включить удаление). 
    html_strip = 1
}


#############################################################################
## indexer settings
#############################################################################

indexer
{
    # Лимит памяти для работы индексатора
    mem_limit = 128M
}

#############################################################################
## searchd settings
#############################################################################

searchd
{
    listen = 9306:mysql41

    # Место хранения логов работы searchd.
    # Внимание! Папки должны быть созданы самостоятельно.
    log = /home/user/sphinx/env-pg/searchd.log

    # Место хранения логов запросов.
    # Внимание! Папки должны быть созданы самостоятельно.
    query_log = /home/user/sphinx/env-pg/query.log

    # Тайм-аут чтения в секундах
    read_timeout = 5
    
    client_timeout = 300
    
    # Максимальное количество форков
    max_children = 30
    
    # Максимальное количество одновременных постоянных подключений к удаленным постоянным агентам .
    persistent_connections_limit = 30
    pid_file = /home/user/sphinx/env-pg/searchd.pid
    
    # Предотвращает searchdзависания при ротации индексов с огромными объемами данных для предварительного кэширования.
    # Необязательно, по умолчанию - 1 (включить плавное вращение).
    seamless_rotate = 1
    
    # Следует ли принудительно предварительно открывать все индексы при запуске.
    # Необязательно, по умолчанию - 1 (предварительно открыть все).
    preopen_indexes = 1

    # Следует ли отменять привязку копий индекса .old при успешной ротации.
    # Необязательно, по умолчанию - 1 (отменить связь). 
    unlink_old = 1

    # Многопроцессорный режим (MPM).
    # С RT работает только режим threads.
    workers = threads
    
    # Путь к файлам двоичного журнала (также известного как журнал транзакций).
    # Необязательно, по умолчанию используется каталог данных, настроенный во время сборки. 
    # Внимание! Папки должны быть созданы самостоятельно.
    binlog_path = /home/user/sphinx/env-pg/data/
}


#############################################################################
## common settings
#############################################################################

common
{

}

# --eof--
```

---
Создадим bash скрипт `pg-env-indexer.sh` со следующим содержимым:
```
./src/bin/indexer --config ./env-pg/sphinx-pg.conf --all --rotate
```

Запустим скрипт: `bash pg-env-indexer.sh`

Ответ будет примерно таким:
```
using config file './env-pg/sphinx-pg.conf'...
FATAL: no indexes found in config file './env-pg/sphinx-pg.conf'
```

И это нормально, ведь у нас используются rt индексы.

---

Создадим bash скрипт `pg-env-searchd.sh`:
```
./src/bin/searchd --config ./env-pg/sphinx-pg.conf
```

Запустим скрипт: `bash pg-env-searchd.sh`

Ответ будет примерно таким:
```
using config file './env-pg/sphinx-pg.conf'...
listening on all interfaces, port=9306
precaching index 'sphinx___news_news'
precaching index 'sphinx___news_article'
precached 2 indexes using 2 threads in 0.0 sec
```

---

Для соединения со Sphinx необходимо установить `libpq-dev`:

`sudo apt install libpq-dev`


# Настройка Django

Для интеграции с Sphinx используется пакет:
https://pypi.org/project/django-sphinxsearch/

```
pip install django==3.0
pip install django_sphinxsearch
```

В настройках Django приложения `settings.py` внести следующие изменения:
```
INSTALLED_APPS = [
    ...
    'sphinxsearch',
    ...
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': db_name,
        'USER': db_user,
        'PASSWORD': db_pass,
        'HOST': '127.0.0.1',
        'PORT': '5432',
    },
    'sphinx': {
        'ENGINE': 'sphinxsearch.backend.sphinx',
        'NAME': 'sphinx',
        'HOST': '127.0.0.1',
        'PORT': '9306',
        'OPTIONS': {
            'use_unicode': True,
        }
    }
}

DATABASE_ROUTERS = ['sphinxsearch.routers.SphinxRouter']

SILENCED_SYSTEM_CHECKS = ['models.E028']

```


Создать приложение:
```
python manage.py startapp news
```

В настройках Django приложения `settings.py` внести следующие изменения:
```
INSTALLED_APPS = [
    ...
    'news',
    ...
]
```

Создать модели:
```

class News(spx_models.SphinxModel):
    title = models.CharField(
        verbose_name='название',
        max_length=256,
    )
    content = models.TextField(
        verbose_name='содержимое',
    )

    class Meta:
        verbose_name = 'новость'
        verbose_name_plural = 'новости'


class Article(spx_models.SphinxModel):

    id = models.AutoField(
        verbose_name='идентификатор',
        primary_key=True,
    )

    title = models.CharField(
        verbose_name='название',
        max_length=256,
    )
    content = models.TextField(
        verbose_name='содержимое',
    )

    class Meta:
        verbose_name = 'статья'
        verbose_name_plural = 'статьи'

```

Создаём миграции:
```
python manage.py makemigrations
python manage.py migrate
```

# Особые моменты

- Нужно использовать `models.AutoField` иначе он не будет сам создавать id
- Важно указывать с какой DB работаем (используем в QS `.usage('default')`)
- После создания/удаления/обновления записи надо повторить манипуляцию в индексе sphinx
