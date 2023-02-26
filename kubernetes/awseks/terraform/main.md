# EKS - EKSCTL

eksctl create cluster --name ${CLUSTER_NAME} --spot  --node-type t3a.medium --nodes 1 --nodes-min 1 --nodes-max 2 --node-volume-size 20  --region ${REGION}

# EKS - Terraform

terraform init

terraform apply 

terraform destroy


# IAM Role Integration & RBAC

Create AWS Role & Map it in the cluster using below command

eksctl create iamidentitymapping \
  --cluster ${CLUSTER_NAME} \
  --arn arn:aws:iam::${ACCOUNT_ID}:role/${CLUSTER_NAME}Dev \
  --username ${USERNAME}

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/misc/clusterrole-user.yaml

kubectl create rolebinding poweruser-${USERNAME} --user ${USERNAME} --clusterrole poweruser --namespace ${USERNAME}

#  Misc - Install Terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform
# Misc - EKSCTL
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
# Misc -  kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl