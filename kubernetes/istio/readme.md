# Install Istio

```
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm ls -n istio-system

helm install istiod istio/istiod -n istio-system --wait
```
```
helm status istiod -n istio-system
helm get all istiod -n istio-system
```
# Sample app
Ref: https://istio.io/latest/docs/examples/microservices-istio/bookinfo-kubernetes/


```
kubectl apply -l version!=v2,version!=v3 -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl scale deployments --all --replicas 3
```
# Test the app
```
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/curl/curl.yaml

kubectl exec $(kubectl get pod -l app=curl -o jsonpath='{.items[0].metadata.name}') -c curl -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
```

## Test on of the microservices (rating)
kubectl exec $(kubectl get pod -l app=curl -o jsonpath='{.items[0].metadata.name}') -- curl -sS http://ratings:9080/ratings/7

## Terminate microservice - details
kubectl exec $(kubectl get pods -l app=details -o jsonpath='{.items[0].metadata.name}') -- pkill ruby

# Generate load

```
k exec -it svc/curl -- sh

while :; do curl -s productpage:9080/productpage | grep -o "<title>.*</title>"; sleep 1; done
```
# Version Upgrade
## Upgrade reviews microservice for internal test
curl -s https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/platform/kube/bookinfo.yaml | sed 's/app: reviews/app: reviews_test/' | kubectl apply -l app=reviews_test,version=v2 -f -

## Internal test
```
REVIEWS_V2_POD_IP=$(kubectl get pod -l app=reviews_test,version=v2 -o jsonpath='{.items[0].status.podIP}')
echo $REVIEWS_V2_POD_IP

kubectl exec $(kubectl get pod -l app=curl -o jsonpath='{.items[0].metadata.name}') -- curl -sS "$REVIEWS_V2_POD_IP:9080/reviews/7"
```
## release reviews v2 once internal tests are OK - but to a small subset of users
kubectl label pods -l version=v2 app=reviews --overwrite
## If no issues from this small subset of users, do full release of v2
```
kubectl scale deployment reviews-v2 --replicas=3
kubectl delete deployment reviews-v1
```

# Enable istio injection
kubectl label namespace default istio-injection=enabled --overwrite
kubectl get namespace -L istio-injection

## Apply destination rules 
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/networking/destination-rule-all.yaml

## Redeploy product page
k rollout restart deploy productpage-v1

# User commands
kubectl apply -l version!=v2,version!=v3 -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/bookinfo/platform/kube/bookinfo.yaml

## Verify calls via proxy
```
kubectl exec $(kubectl get pods -l app=productpage -o jsonpath='{.items[0].metadata.name}') -c istio-proxy -- curl -X POST "http://localhost:15000/logging?level=debug"

kubectl logs -l app=productpage -c istio-proxy | grep productpage
```

# References:
- https://istio.io/latest/docs/ops/deployment/deployment-models/
- Traffic shifting / Canary Deployment - https://istio.io/latest/docs/tasks/traffic-management/traffic-shifting/
- Fault Injection https://istio.io/latest/docs/tasks/traffic-management/fault-injection/
- Request routing https://istio.io/latest/docs/tasks/traffic-management/request-routing/
- Rate Limit - https://istio.io/latest/docs/tasks/policy-enforcement/rate-limit/
- mTLS - https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/ 
- mTLS (DestinationRule) - https://istio.io/latest/docs/reference/config/networking/destination-rule/
