# Cluster setup - Admin
Below steps to be taken by admin to setup the cluster using EKSCTL

## EKSCTL

eksctl create cluster --name microk8s --spot --node-type t3a.medium --nodes 1 --nodes-min 1 --nodes-max 2 --node-volume-size 20 --version  1.21
OR
eksctl create cluster -f ./cluster/cluster.yaml

eksctl create nodegroup --name ng-zone-1a --cluster microk8s --nodes 3 --node-type t3a.xlarge --spot --nodes-min 1 --nodes-max 3 --node-volume-size 20 --node-zones ap-southeast-1a

eksctl create nodegroup --name ng-zone-1b --cluster microk8s --nodes 1 --node-type t3a.xlarge --spot --nodes-min 1 --nodes-max 1 --node-volume-size 20 --node-zones ap-southeast-1b

eksctl create nodegroup --name ng-zone-1c --cluster microk8s --nodes 1 --node-type t3a.xlarge --spot --nodes-min 1 --nodes-max 1 --node-volume-size 20 --node-zones ap-southeast-1c

## Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/aws/deploy.yaml


## Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

## cert manager

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.0/cert-manager.yaml

k apply -f cert-manager/cluster-issuer-letsencrypt.yaml

Ref: https://cert-manager.io/docs/installation/kubectl/

## Cluster Autoscaler - karpenter
https://karpenter.sh/v0.9.1/getting-started/getting-started-with-eksctl/

## User Access

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/misc/clusterrole-user.yaml

eksctl create iamidentitymapping --cluster microk8s \
  --arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/microk8sAdmin \
  --username klaas2205u

scbcepb3u1   scbcepb3u  Dev Role (RBAC)

for i in {1..1};do kubectl create ns  klaas2205u$i;done

for i in {1..1};do kubectl create rolebinding poweruser-klaas2205u --user klaas2205u --clusterrole poweruser --namespace klaas2205u$i;done

## Observability - Weather Application
https://github.com/brainupgrade-in/kubernetes/tree/main/observability

## Misc apps using HELM

helm repo add stable https://charts.helm.sh/stable

helm repo update
