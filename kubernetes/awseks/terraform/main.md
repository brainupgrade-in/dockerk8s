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
