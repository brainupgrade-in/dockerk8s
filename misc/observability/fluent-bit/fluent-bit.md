helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

helm upgrade --install fluent-bit fluent/fluent-bit \
--namespace fluent-bit --create-namespace \
--set backend.type=es \
--set backend.es.host=es-elasticsearch-master-hl.elasticsearch.svc \
--set backend.es.port=9200 \
--set dashboards.enabled=true

kubectl delete cm fluent-bit -n fluent-bit

kubectl create cm fluent-bit -n fluent-bit \
--from-file=fluent-bit.conf=fluent-bit.conf \
--from-file=custom_parsers.conf=custom_parsers.conf

kubectl set env ds fluent-bit -n fluent-bit \
 FLUENT_ELASTICSEARCH_HOST=es-elasticsearch-master-hl.elasticsearch.svc \
 FLUENT_ELASTICSEARCH_PORT=9200