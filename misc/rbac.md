# Create User
openssl genrsa -out /home/ubuntu/${user}.key 2048
openssl req -new -key /home/ubuntu/${user}.key -out /home/ubuntu/${user}.csr -subj "/CN=${user}/O=${user}"
openssl x509 -req -in /home/ubuntu/${user}.csr -CAkey /home/ubuntu/ca.key -CA /home/ubuntu/ca.crt -CAcreateserial -out ${user}.crt -days 365

# copy ca.crt and ca.key from master node
kubectl create ns ${user}
# kubectl create sa ${user} --namespace ${user}

c=`kubectl config current-context`
cluster_name=`kubectl config get-contexts $c | awk '{print $3}' | tail -n 1`
endpoint=`kubectl config view -o jsonpath="{.clusters[?(@.name == \"${cluster_name}\")].cluster.server}"`

# Set up the config
KUBECONFIG=/home/ubuntu/kube-conf-${user} kubectl config set-cluster ${cluster_name} \
    --embed-certs=true \
    --server=${endpoint} \
    --certificate-authority=/home/ubuntu/ca.crt

KUBECONFIG=/home/ubuntu/kube-conf-${user}  kubectl config set-credentials ${user} \
    --client-key=/home/ubuntu/${user}.key --client-certificate=/home/ubuntu/${user}.crt --embed-certs=true

KUBECONFIG=/home/ubuntu/kube-conf-${user} kubectl config set-context ${user}-${cluster_name#cluster-} \
    --cluster=${cluster_name} \
    --user=${user} --namespace=${user}
KUBECONFIG=/home/ubuntu/kube-conf-${user} kubectl config use-context ${user}-${cluster_name#cluster-}

# Create Rolebinding
kubectl create rolebinding ${name} --user ${user} --clusterrole ${simpleuser} --namespace ${user}
kubectl create clusterrolebinding ${name} --user ${user} --clusterrole ${power-user} 


echo "export KUBECONFIG=/home/ubuntu/kube-conf-${user}"
echo "KUBECONFIG=/home/ubuntu/kube-conf-${user} kubectl get pods"
KUBECONFIG=/home/ubuntu/kube-conf-${user} kubectl get pods
chmod 644 /home/ubuntu/kube-conf-${user}
