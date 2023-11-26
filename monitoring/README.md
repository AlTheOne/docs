# Monitoring

Stack:
- Prometheus
- Grafana
- node-exporter
- cAdvisor


## Features

### cAdvisor image
For monitoring containers use docker image `gcr.io/cadvisor/cadvisor` instread of `google/cadvisor` because get error:

```
1 cadvisor.go:134] Failed to create a Container Manager: mountpoint for cpu not found
```

Issue: [source](https://github.com/google/cadvisor/issues/1943)


### Recomended Grafana Dasboards
- [1 Node Exporter 0.16 + for Prometheus Monitoring display board](https://grafana.com/grafana/dashboards/10795-1-node-exporter-0-16-for-prometheus-monitoring-display-board/)
- [Docker Monitoring](https://grafana.com/grafana/dashboards/193-docker-monitoring/)
- [Cadvisor exporter](https://grafana.com/grafana/dashboards/14282-cadvisor-exporter/)
