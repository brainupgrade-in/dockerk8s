
# Cluster scope

## Elastic Search

```
helm install es oci://registry-1.docker.io/bitnamicharts/elasticsearch --set master.persistence.size=1Gi --set data.persistence.size=1Gi --set master.replicaCount=1 --set data.replicaCount=1 --namespace elasticsearch --create-namespace

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/misc/observability/fluent-bit/fluent-bit.yaml

helm install kibana oci://registry-1.docker.io/bitnamicharts/kibana --set persistence.size=1Gi --set elasticsearch.hosts[0]=es-elasticsearch.elasticsearch.svc  --set elasticsearch.port=9200 --set service.type=NodePort  --namespace elasticsearch --create-namespace

```

### Access kibana

Access dashboard using:
`kubectl port-forward -n elasticsearch svc/kibana 5601:5601`


## APM Server

`kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/07a-apm-server.yaml`

## Prometheus - Grafana

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --create-namespace=true --namespace monitoring

helm install grafana grafana/grafana --set service.type=NodePort --namespace monitoring --values grafana/grafana-values.yaml
```

# Grafana access

Get Password using: `kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

Access dashboard using:

`kubectl port-forward -n monitoring svc/grafana 3000:80`

# User Scope - App Deployment (weather app )

# Secrets & Configuration

```
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08b-config.yaml
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08c-secret.yaml

```

## Database / Backend Service

`kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/06c-microservices-weather-db.yaml`

## Middle layer service

`kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08e-metrics-weather-services.yaml`

## Frontend / User Interface Service

`kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08d-metrics-weather-front.yaml`

# Publish App to the internet - Ingress

Update ingress by routing URL requests to weather-front service & verify the app is working
