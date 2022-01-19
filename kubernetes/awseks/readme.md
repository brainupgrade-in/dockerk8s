# Cluster Admin Environment
kubectl create deploy k8sadmin --image brainupgrade/k8stools:1.0.0 -- tail -f /dev/null

kubectl exec -it deploy/k8sadmin -- bash

# EKSCTL

eksctl create cluster -f ./autoscaling-cluster/cluster.yaml


eksctl create cluster --name k8sadmin --spot --node-type t3a.small --nodes 1 --nodes-min 1 --nodes-max 2 --node-volume-size 20 --version  1.20

# Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/aws/deploy.yaml


# Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

# cert manager
helm repo add jetstack https://charts.jetstack.io

helm repo update

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.0/cert-manager.yaml

k apply -f cluster-issuer-letsencrypt.yaml

Ref: https://cert-manager.io/docs/installation/kubectl/

# Observability - Weather Application
https://github.com/brainupgrade-in/kubernetes/tree/main/observability

# HELM
helm repo add stable https://charts.helm.sh/stable

helm repo update

helm install kube-ops-view stable/kube-ops-view --set service.type=LoadBalancer --set rbac.create=True

kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
