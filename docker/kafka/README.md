# Kafka


Полезные команды:
---

```bash
docker exec -it kafka /bin/bash
```

Создать топик:
```bash
./kafka-topics.sh --bootstrap-server kafka:9092 --create --topic client --partitions 1 --replication-factor 1
```

Список топиков:
```bash
./kafka-topics.sh --bootstrap-server kafka:9092 --list
```

Полезные ресурсы:
---

- https://dev.to/thegroo/one-to-run-them-all-1mg6
- https://towardsdatascience.com/kafka-docker-python-408baf0e1088