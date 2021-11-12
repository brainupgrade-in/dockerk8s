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
05b+c+d
## APM Server
07a
## Prometheus - Grafana
helm repo add prometheus-community	https://prometheus-community.github.io/helm-charts
helm repo add grafana	https://grafana.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --create-namespace=true --namespace monitoring
helm install grafana grafana/grafana  --create-namespace=true --namespace monitoring
### Grafana access
Get Password using: kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
// 8zUNCJ53l3NxUrC5UbyxnYhkbHiBcQjSHBUyJaf5
Access dashboard using: 
kubectl port-forward -n monitoring svc/grafana 3000:80

# User Scope - App Deployment (weather app )
## Database / Backend Service
06c
## Middle layer service
08c
## Frontend / User Interface Service 
08b

# Publish App to the internet - Ingress 
Update ingress by routing URL requests to weather-front service & verify the app is working