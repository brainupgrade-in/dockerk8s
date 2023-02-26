# Useful commands

## Update the ingress

 for i in {1..25}; \
do kubectl patch ingress/user$i-app.<URL> -n user$i --type=json \
  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value":"app"},{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value":80}]' ; \
  done

## Update quota
kubectl  patch resourcequota compute-resources --type='json' -p='[{"op":"replace","path":"/spec/hard/requests.storage","value":"20Gi"}]'

for node in $(kubectl get nodes -ojsonpath='{..metadata.name}'); do echo $node;done

# View events
k -n team-red get events --sort-by='{.metadata.creationTimestamp}'