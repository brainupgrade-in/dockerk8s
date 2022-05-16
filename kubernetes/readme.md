 # Update the ingress

 for i in {1..1}; \
do kubectl patch ingress/klaas2205u$i-app.brainupgrade.in -n klaas2205u$i --type=json \
  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value":"docker"},{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value":80}]' ; \
  done
