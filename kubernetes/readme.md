 # Update the ingress

 for i in {1..25}; \
do kubectl patch ingress/user$i-app.<URL> -n user$i --type=json \
  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value":"app"},{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value":80}]' ; \
  done
