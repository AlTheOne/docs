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

---

- Получить команду для подключения вычислительного узла
```shell
kubeadm token create --print-join-command
```

---

- Разрешить запускать pod'ы на вычислительным узле
```shell
kubectl taint node kubernetes-master node-role.kubernetes.io/master:NoSchedule-
```
