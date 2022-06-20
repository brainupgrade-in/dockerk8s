# cert manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.0/cert-manager.yaml
k apply -f cluster-issuer-letsencrypt.yaml
Ref: https://cert-manager.io/docs/installation/kubectl/

# Metrics Server
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update 
helm install metrics-server bitnami/metrics-server --create-namespace=true --namespace metrics-server
helm upgrade --namespace metrics-server metrics-server bitnami/metrics-server --set apiService.create=true
and Edit deploy spec by adding below args  (kubectl edit deploy -n metrics-server)
    - --kubelet-insecure-tls=true
    - --kubelet-preferred-address-types=InternalIP
    - --kubelet-use-node-status-port
    - --metric-resolution=15s    

kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"

# Cluster Autoscaler (Alternate: Karpenter)
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install cluster-autoscaler stable/cluster-autoscaler --set autoDiscovery.clusterName=<cluster-name>
kubectl --namespace=default get pods -l "app=aws-cluster-autoscaler,release=cluster-autoscaler"

# List db instances in all aws regions
aws ec2 describe-regions --query Regions[*].[RegionName] --output text | xargs -n 1 aws rds describe-db-instances --region

# SSH Server
kubectl create deploy ssh-server --image linuxserver/openssh-server
kubectl set env deploy ssh-server SUDO_ACCESS=true PASSWORD_ACCESS=true USER_PASSWORD=linux USER_NAME=ubuntu
kubectl expose deploy ssh-server --port 22 --target-port 2222