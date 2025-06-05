# POD
kubectl get pods --sort-by=.metadata.name
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
kubectl get pods --selector=app=cassandra -o jsonpath='{.items[*].metadata.labels.version}'
kubectl get pods --field-selector=status.phase=Running
kubectl get pods --show-labels
## List all Secrets currently in use by a pod
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq

# Delete pods using label
kubectl get pods -o name --selector=app=hello  |xargs -I {} kubectl delete {}

k get nodes -ojson | jq '.items[]|{name:.metadata.name,cap:.status.capacity}'
kubectl get pv --sort-by=.spec.capacity.storage
kubectl get node --selector='!node-role.kubernetes.io/master'
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"

# Patch Ingress with new service name
kubectl patch ingress rajesh-app.brainupgrade.in  --type=json \
 -p='[{"op":"replace","path":"/spec/rules/0/http/paths/0/backend/service/name","value":"hello"}]'

# Patch svc port
kubectl patch svc test --type='json' -p='[{"op": "add", "path": "/spec/ports", "value": [{"name": "dind","port":2375,"protocol":"TCP","targetPort":2375 },{"name": "docker","port":80,"protocol":"TCP","targetPort":80 },{"name": "main","port":8080,"protocol":"TCP","targetPort":8080 }] }]'

# Too many docker pull requests - issue
unexpected status code https://registry-1.docker.io/v2/brainupgrade/docker/manifests/sha256:173738a1999b3a3f40c9aa624c1d81cd770da6560342ba3670b3d5df31ec5497: 429 Too Many Requests - Server message: toomanyrequests: You have reached your unauthenticated pull rate limit. https://www.docker.com/increase-rate-limit

## Solution
- Create kubernetes secret containing docker registry credentials
kubectl create secret docker-registry regcred --docker-username=  --docker-password=  --docker.email=
- Assign this secret to sa
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'
