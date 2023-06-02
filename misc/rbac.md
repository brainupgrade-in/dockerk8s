# Create User
openssl genrsa -out /home/unigps/${user}.key 2048
openssl req -new -key /home/unigps/${user}.key -out /home/unigps/${user}.csr -subj "/CN=${user}/O=${user}"
openssl x509 -req -in /home/unigps/${user}.csr -CAkey /home/unigps/ca.key -CA /home/unigps/ca.crt -CAcreateserial -out ${user}.crt -days 365

# copy ca.crt and ca.key from master node
kubectl create ns ${user}
# kubectl create sa ${user} --namespace ${user}

c=`kubectl config current-context`
cluster_name=`kubectl config get-contexts $c | awk '{print $3}' | tail -n 1`
endpoint=`kubectl config view -o jsonpath="{.clusters[?(@.name == \"${cluster_name}\")].cluster.server}"`

# Set up the config
KUBECONFIG=/home/unigps/kube-conf-${user} kubectl config set-cluster ${cluster_name} \
    --embed-certs=true \
    --server=${endpoint} \
    --certificate-authority=/home/unigps/ca.crt

KUBECONFIG=/home/unigps/kube-conf-${user}  kubectl config set-credentials ${user} \
    --client-key=/home/unigps/${user}.key --client-certificate=/home/unigps/${user}.crt --embed-certs=true

KUBECONFIG=/home/unigps/kube-conf-${user} kubectl config set-context ${user}-${cluster_name#cluster-} \
    --cluster=${cluster_name} \
    --user=${user} --namespace=${user}
KUBECONFIG=/home/unigps/kube-conf-${user} kubectl config use-context ${user}-${cluster_name#cluster-}

# Create Rolebinding
kubectl create rolebinding ${user} --user ${user} --clusterrole poweruser --namespace ${user}
kubectl create clusterrolebinding ${name} --user ${user} --clusterrole poweruser


echo "export KUBECONFIG=/home/unigps/kube-conf-${user}"
echo "KUBECONFIG=/home/unigps/kube-conf-${user} kubectl get pods"
KUBECONFIG=/home/unigps/kube-conf-${user} kubectl get pods
chmod 644 /home/unigps/kube-conf-${user}

# Giving user permission to work in other namespace

k create role demo --verb=create,get --resource=pods/exec --resource-name=test --namespace target
k create rolebinding demo --user=user --role demo   (k edit rolebinding and add namespace to the user) --namespace target