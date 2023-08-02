# Kafka in Kubernetes
- Reference https://strimzi.io/quickstarts/

# Setup
- ``` kubectl create namespace kafka ```
- ```kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka```
- ```kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-persistent-single.yaml -n kafka``` 

# Test
## Producer
```
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.31.1-kafka-3.2.3 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic
```

## Consumer
```
kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.31.1-kafka-3.2.3 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning
```
# Kafka from Bitnami
helm install kafka oci://registry-1.docker.io/bitnamicharts/kafka --set persistence.size=1Gi

kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.4.1-debian-11-r0 --namespace mtvlabeksa1 --command -- sleep infinity

Producer:
kafka-console-producer.sh \
            --broker-list kafka-0.kafka-headless.mtvlabeksa1.svc.cluster.local:9092 \
            --topic test

Client:
kafka-console-consumer.sh \
            --bootstrap-server kafka.mtvlabeksa1.svc.cluster.local:9092 \
            --topic test \
            --from-beginning            

