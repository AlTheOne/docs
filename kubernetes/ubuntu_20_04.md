# Установка Kubernetes на Ubuntu 20.04

**Минимальная конфигурация:** \
CPU: 2 core \
RAM: 2 Gb \
ROM: 10 Gb

При развёртвынии на VPS убедитесь, что на VPS не подключён SWAP или хостинг предоставляет возможность отключения SWAP.[^1]

На практике были опробованы хостинги:
- [Jino](https://jino.ru/) (не удалось отключить SWAP)
- [HSHP](https://hshp.host/) (удалось отключить SWAP)

---
# Обновление системы

> Выполнить на:
> - Упраляющем узле
> - Вычислительном узле

1. Обновите индекс пакетов и списки пакетов
```
sudo apt update
```

2. Обновите пакеты OS
```
sudo apt upgrade
```

# Отключение SWAP

Для работы Kubernetes необходимо отключи подкачу памяти.\
Иначе можно получить ошибку при запуске `kubeadm`:

> [ERROR Swap]: running with swap on is not supported. Please disable swap

1. Отключите swap для текущей сессии:
```
sudo swapoff -a
```

2. Чтобы отключить swap навсегда, отредактируйте файл `/etc/fstab`:
```
sudo nano /etc/fstab
```

<details> 
  <summary>БЫЛО: /etc/fstab</summary>

```
/dev/disk/by-uuid/a24f00e7-918a-4a05-b4c9-35bdef750fb4 / ext4 defaults 0 0
/swap.img       none    swap    sw      0       0
```

</details>

<details> 
  <summary>СТАЛО: /etc/fstab</summary>

```
/dev/disk/by-uuid/a24f00e7-918a-4a05-b4c9-35bdef750fb4 / ext4 defaults 0 0
# /swap.img       none    swap    sw      0       0
```
</details>

# Docker

> Выполнить на:
> - Упраляющем узле
> - Вычислительном узле

1. Установите Docker
```
sudo apt install docker.io
```

2. Активируйте службу Docker
```
sudo systemctl enable docker
```

3. Запустите службу Docker
```
sudo systemctl start docker
```

4. Проверьте работоспособность службы
```
sudo systemctl status docker
```

Служба должна быть активна:
![Статус службы docker](https://img.reg.ru/faq/kubernetes-240820-1.png)

5. Добавьте cgroup driver для Docker.[^2]

Для этого есть несколько способов:

I. Добавить флаг запуска `--exec-opt native.cgroupdriver=systemd` в `docker.service` \
Обычно файл имеет путь: `/etc/systemd/system/multi-user.target.wants/docker.service`, но 
если его нет, то можно поискать его командами:
- Find: `sudo find /etc -name docker.serivce`
- Locate: обновить базу - `updatedb` и выполнить поиск `locate docker.service`

В файле `docker.service` добавить флаг `--exec-opt native.cgroupdriver=systemd` в директиву `ExecStart=...`

<details> 
  <summary>БЫЛО: docker.service</summary>
  
```
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
```
</details>


<details> 
  <summary>СТАЛО: docker.service</summary>
  
```
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
```
</details>

Перезапустите службу docker.serivce
```
sudo systemctl restart docker.service
```

II. Отредактировать файл `daemon.json`. Обычно файл находится по пути `/etc/docker/daemon.json` \
В файл необходимо добавить
```json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

Перезапустите службу docker.serivce
```
sudo systemctl restart docker.service
```

# Установка Kubernetes
1. Скачайте и устанавите GPG-ключ
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
```

2. Добавьте репозиторий Kubernetes
```
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
```

3. Установите пакеты Kubernetes
```
sudo apt install kubeadm kubelet kubectl
```

4. Исключите пакеты из обновления.[^3] \
Данный шаг рекомендован, чтобы при обновлении системы пакеты Kubernetes не были обновлены автоматически и не нарушили работоспособнось кластера.
```
sudo apt-mark hold kubeadm kubelet kubectl
```

5. Выполните проверку версии `kubeadm`
```
kubeadm version
```

---
Полезные ссылки
[^1]: [SWAP](https://help.ubuntu.ru/wiki/swap)
[^2]: [Проблемы с установкой при различных cgroup](https://russianblogs.com/article/5706308202/)
[^3]: [Удержание apt пакетов от обновления](https://itisgood.ru/2020/03/05/tri-sposoba-iskljuchit-uderzhat-predotvratit-obnovlenie-opredelennogo-paketa-s-apt-upgrade/)
