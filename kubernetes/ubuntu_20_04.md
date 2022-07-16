# Установка Kubernetes на Ubuntu 20.04

---

## Содержание
- [Минимальная конфигурация](#Минимальная-конфигурация)
- [Развёртывание на VPS](#Развёртывание-на-VPS)
- [Обновление системы](#Обновление-системы)
- [Отключение SWAP](#Отключение-SWAP)
- [Установка Docker](#Установка-Docker)
- [Установка Kubernetes](#Установка-Kubernetes)
- [Настройка управляющего узла Kubernetes](#Настройка-управляющего-узла-Kubernetes)
- [Настройка вычислительного узла Kubernetes](#Настройка-вычислительного-узла-Kubernetes)
- [Альтернативные инструкции установки](#Альтернативные-инструкции-установки)

---

# Минимальная конфигурация
CPU: 2 core \
RAM: 2 Gb \
ROM: 10 Gb


# Развёртывание на VPS
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

> Выполнить на:
> - Упраляющем узле
> - Вычислительном узле

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

# Установка Docker

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

I. Добавить флаг запуска `--exec-opt native.cgroupdriver=systemd` в `docker.service` в директиву `ExecStart=...` \

Обычно файл имеет путь: `/etc/systemd/system/multi-user.target.wants/docker.service`, но 
если его нет, то можно поискать его командами:
- Find: `sudo find /etc -name docker.serivce`
- Locate: обновить базу - `updatedb` и выполнить поиск `locate docker.service`

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

> Выполнить на:
> - Упраляющем узле
> - Вычислительном узле

1. Скачайте и устанавите GPG-ключ
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
```

2. Добавьте репозиторий Kubernetes
```
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
```

3. Обновите индекс пакетов:
```
sudo apt update
```

4. Установите пакеты Kubernetes
```
sudo apt install kubeadm kubelet kubectl
```

5. Исключите пакеты из обновления.[^3] \
Данный шаг рекомендован, чтобы при обновлении системы пакеты Kubernetes не были обновлены автоматически и не нарушили работоспособнось кластера.
```
sudo apt-mark hold kubeadm kubelet kubectl
```

6. Выполните проверку версии `kubeadm`
```
kubeadm version
```


# Настройка управляющего узла Kubernetes

> Выполнить на:
> - Упраляющем узле

1. Измените на машине hostname [^4]
```
sudo hostnamectl set-hostname kubernetes-master
```

Где `kubernetes-master` - название узла.

2. Инициализируйте управляющий узел
```
sudo kubeadm init
```

Пример успешной инициализации:
![Инициализация управляющего узла kubernetes](https://img.reg.ru/faq/kubernetes-240820-3.png)

> [!] Скопируйте и сохраните вывод информации о команде `kubeadm join` для присоединения рабочих нод к кластеру.

3. Создайте директорию для кластера
```
mkdir -p $HOME/.kube
```

4. Создайте символическую ссылку на файл настроек
```
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

5. Поменяйте группу и владельца
```
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

6. Подключите поставщик оверлейной сети Flannel. \
Используется для коммуникации между нодами в кластере
```
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

Проверьте, что сеть развёрнута:
```
sudo kubectl get pods --all-namespaces
```


# Настройка вычислительного узла Kubernetes

> Выполнить на:
> - Вычислительном узле

1. Изменить на машине hostname [^4]
```
sudo hostnamectl set-hostname kubernetes-node01
```

Где `kubernetes-node01` - название узла.

2. Подключите вычислительный узел к управляемому.\
Используйте команду полученную при успешной инициализации управляющего узла. 
```
sudo kubeadm join <host>:<port> --token <some_token> --discovery-token-ca-cert-hash sha256:<some_hash>
```

---

# Альтернативные инструкции установки
- [Руководство по Kubernetes от REG.ru](https://help.reg.ru/hc/ru/articles/4408047657105-%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE-%D0%BF%D0%BE-Kubernetes)
- [Установка Kubernetes на Ubuntu Linux](https://techexpert.tips/ru/kubernetes-ru/%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-kubernetes-%D0%BD%D0%B0-ubuntu-linux/)


Полезные ссылки

[^1]: [SWAP](https://help.ubuntu.ru/wiki/swap)
[^2]: [Проблемы с установкой при различных cgroup](https://russianblogs.com/article/5706308202/)
[^3]: [Удержание apt пакетов от обновления](https://itisgood.ru/2020/03/05/tri-sposoba-iskljuchit-uderzhat-predotvratit-obnovlenie-opredelennogo-paketa-s-apt-upgrade/)
[^4]: [Изменение hostname](https://userman.ru/2019/12/15/kak-izmenit-hostname-v-linux.html)
