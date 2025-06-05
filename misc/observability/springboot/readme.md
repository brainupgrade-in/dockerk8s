# Logs - Loki
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/01-k8s-loki.yaml

# Distributed Tracing - Tempo
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/02-k8s-tempo.yaml

# Log shipping agent - promtail
wget https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/03b-k8s-promtail.yaml

sed -i 's/\${POD_NAMESPACE}/<user>/g' 03b-k8s-promtail.yaml

kubectl apply -f 03b-k8s-promtail.yaml
## Admin step
wget https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/03a-k8s-promtail-rbac.sh
./03a-k8s-promtail-rbac.sh <user|namespace>

# Prometheus 
## RBAC (Admin step)
wget https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/04-k8s-prometheus-rbac.sh

./04-k8s-prometheus-rbac.sh <user|namespace>
## Set SA 
kubectl set sa sts/prometheus prometheus

# Deploy spring boot app
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/05-k8s-obs-springboot-prom-otel.yaml

# Grafana
## Loki DB
Add loki datasource and configure it as below:
    Name: TraceId Regex: (?:trace_id)=(\w+) 
    
    
    Query: # ${__value.raw}
## Tempo UI Config
### Trace to Log 
Datasource: Loki
Span start: -5m
Span End: 5m
Tags: pod
Filter by trace ID: true    
### Trace to matrics
Data Source: Prometheus
Span start: -5m
Span end: 5m
Tags:  service.name as pod  http.route as uri

Link Label: Request Rate  Query: sum by(uri)(rate(http_server_requests_seconds_count{$__tags}[1m]))

Link Label: Error Rate  Query: sum by (client, server)(rate(traces_service_graph_request_failed_total{$__tags}{$__rate_interval))

# Dashboard
17175 - Spring boot

# Load Test
    kubectl create deploy loadtest --image brainupgrade/load-test
    kubectl exec -it deploy/loadtest -- bash
## Window 1 -tmux 
curl -fsslO https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/test-load.sh

chmod +x test-load.sh

./test-load.sh obs-springboot 10
## Window 2 - tmux    
curl -fsslO https://raw.githubusercontent.com/brainupgrade-in/obs-graf/refs/heads/main/apps/obs-springboot-prom-otel-tempo-loki/test.sh

chmod +x test.sh

while true; do ./test.sh obs-springboot ;sleep 5s;done