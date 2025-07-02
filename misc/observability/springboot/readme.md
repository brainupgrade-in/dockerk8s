# Observability setup for spring boot app with OTEL instrumentation
## Loki - logs database
```bash
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/01-k8s-loki.yaml
```
## Tempo - Distributed log tracing using trace_id
```bash
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/02-k8s-tempo.yaml
```

### Promtail setup
```bash
wget https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/03b-k8s-promtail.yaml

NAMESPACE=$(kubectl get sa default -o jsonpath='{.metadata.namespace}')
sed -i "s/default/$NAMESPACE/g" 03b-k8s-promtail.yaml

kubectl apply -f 03b-k8s-promtail.yaml
```

# Prometheus 
## Installation
```
https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/refs/heads/main/misc/observability/springboot/prometheus.yaml
```
## Prometheus Config - To auto discover kubernetes services with annotation
```bash
wget https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/prometheus/k8s-discovery/01b-k8s-prometheus-configmap-svc-annotation.yaml

sed -i "s/__NAMESPACE__/$NAMESPACE/g" 01b-k8s-prometheus-configmap-svc-annotation.yaml
kubectl apply -f 01b-k8s-prometheus-configmap-svc-annotation.yaml
```

# Grafana
## Installation
```
kubectl create secret generic grafana --from-literal=GF_SECURITY_ADMIN_USER=$(kubectl get sa default -ojson|jq -r '.metadata.namespace') --from-literal=GF_SECURITY_ADMIN_PASSWORD=$(kubectl get sa default -ojson|jq -r '.metadata.namespace')-pwd

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/refs/heads/main/misc/observability/springboot/grafana.yaml
```
## Setup credentials
```
kubectl set env sts grafana GF_SECURITY_ADMIN_USER=$(kubectl get sa default -ojson|jq -r '.metadata.namespace')
kubectl set env sts grafana GF_SECURITY_ADMIN_PASSWORD=$(kubectl get sa default -ojson|jq -r '.metadata.namespace')-pwd
```
## Update ingress
```
kubectl patch ingress $INGRESS --type=json -p='[{"op":"replace","path":"/spec/rules/0/http/paths/0/backend/service/name","value":"grafana"}]'

kubectl patch ingress $INGRESS --type=json -p='[{"op":"replace","path":"/spec/rules/0/http/paths/0/backend/service/port/number","value":3000}]'
```
# Deploy spring boot app
```bash
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/05-k8s-obs-springboot-prom-otel.yaml
```

# Dashboard
17175 - Spring boot

# Load Test
```bash

tmux
kubectl create deploy loadtest --image brainupgrade/load-test
kubectl exec -it deploy/loadtest -- bash

```
Split the window in two halves (ctrl+b ")

## First tmux window pane
```bash

curl -fsslO https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/test-load.sh

chmod +x test-load.sh

./test-load.sh obs-springboot 10
```
## Second tmux window pane
```bash

kubectl exec -it deploy/loadtest -- bash

curl -fsslO https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/test.sh

chmod +x test.sh

while true; do ./test.sh obs-springboot ;sleep 5s;done

```

# Optional 
## Loki Config
### Enable Tempo -Derived Fields
```
    Name: TraceId Regex: (?:trace_id)=(\w+) 
    
    
    Query: # ${__value.raw}
```
OR 
```
(?:trace_id)=(\w+).*?(?:traceID)=(\w+)
```
Internal Link: Tempo

## Prometheus UI Config
Exemplars

Internal link Tempo
URL: ${__value.raw}
Label: trace_id

## Tempo UI config

### Trace to Logs
    Datasource: Loki
    Span start: -5m
    Span End: 5m
    Tags: pod
    Filter by trace ID: true

### Trace to Metrics
    Data Source: Prometheus
    Span start: -5m
    Span end: 5m
    Tags:  service.name as pod  http.route as uri

    Link Label: Request Rate  Query: sum by(uri)(rate(http_server_requests_seconds_count{$__tags}[1m]))

    Link Label: Error Rate  Query: 
    rate(http_server_requests_seconds_count{status="500"}[$__rate_interval])


## Dashboard Variables - 17175
```
Application: app label_values(service)

Instance: app_name label_values(application)

Log Query: LogRef: log_keyword
```

### Dashboard Panel - Log type rate - Query

sum by(type) (rate({app=~"$app.*"} | pattern `<date> <time> <_>=<trace_id> <_>=<span_id> <_>=<trace_flags> <type> <_> --- <msg>` | type != "" |= "$log_keyword" [1m]))

### Dashboard Panel - Logs of all spring boot panels - Query

{app=~"$app.*"} | pattern `<date> <time> <_>=<trace_id> <_>=<span_id> <_>=<trace_flags> <type> <_> --- <msg>` | line_format "{{.app}}\t{{.type}}\ttrace_id={{.trace_id}}\t{{.msg}}" |= "$log_keyword"

