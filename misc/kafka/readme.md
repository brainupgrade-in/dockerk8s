# Kafka in Kubernetes
- Reference https://strimzi.io/quickstarts/

# Setup
- ``` kubectl create namespace kafka ```
- ```kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka```
- ```kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/misc/kafka/kafka-cluster.yaml -n kafka``` 

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
helm install kafka oci://registry-1.docker.io/bitnamicharts/kafka --set controller.persistence.size=1Gi --set broker.persistence.size=1Gi

kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.4.1-debian-11-r0 --namespace kafka --command -- sleep infinity

Producer:
kafka-console-producer.sh \
            --broker-list kafka-0.kafka-headless.kafka.svc.cluster.local:9092 \
            --topic test

Client:
kafka-console-consumer.sh \
            --bootstrap-server kafka.kafka.svc.cluster.local:9092 \
            --topic test \
            --from-beginning            

** Please be patient while the chart is being deployed **

Kafka can be accessed by consumers via port 19092 on the following DNS name from within your cluster:

    kafka.mtvlabeksa1.svc.cluster.local

Each Kafka broker can be accessed by producers via port 19092 on the following DNS name(s) from within your cluster:

    kafka-controller-0.kafka-controller-headless.mtvlabeksa1.svc.cluster.local:19092
    kafka-controller-1.kafka-controller-headless.mtvlabeksa1.svc.cluster.local:19092
    kafka-controller-2.kafka-controller-headless.mtvlabeksa1.svc.cluster.local:19092

The CLIENT listener for Kafka client connections from within your cluster have been configured with the following security settings:
    - SASL authentication

To connect a client to your Kafka, you need to create the 'client.properties' configuration files with the content below:

security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-256
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="user1" \
    password="$(kubectl get secret kafka-user-passwords --namespace kafka -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d , -f 1)";

To create a pod that you can use as a Kafka client run the following commands:

    kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.5.1-debian-11-r7 --namespace mtvlabeksa1 --command -- sleep infinity
    kubectl cp --namespace mtvlabeksa1 ~/client.properties kafka-client:/tmp/client.properties
    kubectl exec --tty -i kafka-client --namespace mtvlabeksa1 -- bash

    PRODUCER:
        kafka-console-producer.sh --producer.config /tmp/client.properties  --broker-list kafka-controller-0.kafka-controller-headless.kafka.svc.cluster.local:9092,kafka-controller-1.kafka-controller-headless.kafka.svc.cluster.local:9092,kafka-controller-2.kafka-controller-headless.kafka.svc.cluster.local:9092  --topic test

    CONSUMER:
        kafka-console-consumer.sh \
            --consumer.config /tmp/client.properties \
            --bootstrap-server kafka.kafka.svc.cluster.local:19092 \
            --topic test \
            --from-beginning