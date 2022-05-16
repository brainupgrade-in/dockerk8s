# Cluster setup - Admin
Below steps to be taken by admin to setup the cluster using EKSCTL

## EKSCTL

eksctl create cluster -f ./cluster/cluster.yaml

eksctl create cluster --name k8sadmin --spot --node-type t3a.small --nodes 1 --nodes-min 1 --nodes-max 2 --node-volume-size 20 --version  1.20

## Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/aws/deploy.yaml


## Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

## cert manager

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.0/cert-manager.yaml

k apply -f cluster-issuer-letsencrypt.yaml

Ref: https://cert-manager.io/docs/installation/kubectl/

## Cluster Autoscaler - karpenter
https://karpenter.sh/v0.9.1/getting-started/getting-started-with-eksctl/

## Misc apps using HELM

helm repo add stable https://charts.helm.sh/stable
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install kube-ops-view stable/kube-ops-view --set service.type=LoadBalancer --set rbac.create=True

kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'

# User - Apps
## Observability - Weather Application
https://github.com/brainupgrade-in/kubernetes/tree/main/observability

