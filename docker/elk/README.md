# ELK

## Prepare
Create new docker network
```bash
docker network create -d bridge elknet
```

## Elasticsearch

Pull and run Elastic from DockerHub:
```bash
docker run -d --name elasticsearch --net elknet -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e "ELASTIC_PASSWORD=pswd" elasticsearch:8.4.2
```

<hr/>

### Notes

[!] When send request by curl
```
curl localhost:9200

curl: (52) Empty reply from server
```
Resolve:
1. Open `config/elasticsearch.yml`
2. Change `xpack.security.enabled` from `false` to `true:
```
# Enable security features
xpack.security.enabled: false
```

<hr/>

## Kibana

Pull and run Kibana from DockerHub:
```bash
docker run -d --name kibana --net elknet -p 5601:5601 kibana:8.4.2
```

## Connect Kibana and Elasticsearch

1. Open kibana in browser `http://127.0.0.1:5601`
2. Get code for connect kibana to elasticsearch
```bash
docker exec -ti elasticsearch bin/elasticsearch-create-enrollment-token --scope kibana
```
3. Get verify token from kibana:
```bash
docker exec -ti kibana bin/kibana-verification-code
```
4. For Auth set login and password:
- Login: `elastic`
- Password: `pswd`

## Logstash

Pull and run Logstash from DockerHub:
```bash
docker run -d --name logstash --net elknet -v /home/altheone/projects/logstash/pipeline:/usr/share/logstash/pipeline -p 5044:5044 -p 9600:9600 logstash:8.4.2
```

* port `5044` configured in `/pipeline/logstash.conf`

Example:
```
input {
  tcp {
    port => 5044
  }
}
output {
  stdout {
    codec => rubydebug
  }
}

```
