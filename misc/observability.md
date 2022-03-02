# Deploying microservices on Kubernetes Cluster with Observability 
# Cluster scope
## Elastic Search
helm repo add elastic https://helm.elastic.co
helm repo update
helm install  elasticsearch elastic/elasticsearch --set replicas=2 --create-namespace=true --namespace elasticsearch
helm install  kibana elastic/kibana --create-namespace=true --namespace elasticsearch
### Access kibana
Access dashboard using: 
kubectl port-forward -n elasticsearch svc/kibana-kibana 5601:5601
## Fluentd

kubectl create ns fluentd

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/05b-log-monitoring-fluentd-setup-crb.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/05c-log-monitoring-fluentd-setup-cm.yaml


kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/05d-log-monitoring-fluentd.yaml


## APM Server
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/07a-apm-server.yaml

## Prometheus - Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --create-namespace=true --namespace monitoring
helm install grafana grafana/grafana  --create-namespace=true --namespace monitoring
### Grafana access
Get Password using: kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
// FIz7srx2rIZsAGKICqTxiaukcY2LMeAhRldJ4QMb
Access dashboard using: 
kubectl port-forward -n monitoring svc/grafana 3000:80

# Secrets & Configuration

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08b-config.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08c-secret.yaml

# User Scope - App Deployment (weather app )
## Database / Backend Service
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/06c-microservices-weather-db.yaml

## Middle layer service
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08e-metrics-weather-services.yaml

## Frontend / User Interface Service 
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/weather/08d-metrics-weather-front.yaml

# Publish App to the internet - Ingress 
Update ingress by routing URL requests to weather-front service & verify the app is working