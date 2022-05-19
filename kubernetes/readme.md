 # Update the ingress

 for i in {1..25}; \
do kubectl patch ingress/lab2202u$i-app.brainupgrade.in -n lab2202u$i --type=json \
  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value":"docker"},{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value":80}]' ; \
  done
