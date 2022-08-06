# Часто используемые команды k8s

- Настройки для подключения в Lens
```shell
sudo kubectl config view --minify --raw
```

---

- Переустановка кластера
```shell
sudo kubeadm reset
```

* Обязательно обновить данные в папке `.kube`

---

- Изменить дефолтный редактор (вместо Vim). \
В `.bash_alias` добавить `KUBE_EDITOR="micro"`

ИЛИ

Ставьте это перед каждой командой на редактирование
```shell
KUBE_EDITOR="nano" kubectl edit ...
```

---

- Получить команду для подключения вычислительного узла
```shell
kubeadm token create --print-join-command
```

---

- Разрешить запускать pod'ы на вычислительным узле
```shell
kubectl taint node kubernetes-master node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes --all node-role.kubernetes.io/master-
```

---

Если не работает flannel проверьте наличие `/run/flannel/subnet.env`

Содержимое:
```
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
```

Такой конфиг должен быть на всех узлах.
