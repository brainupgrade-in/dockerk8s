create_cluster:
	eksctl create cluster -f cluster.yaml

delete_cluster:
	eksctl delete cluster -f cluster.yaml

create_nodegroup:
	eksctl create nodegroup --config-file=cluster.yaml

create_nodegroup_t3axlarge:
    eksctl create nodegroup --name ng-2 --cluster k2 --nodes 1 --node-type t3a.xlarge --spot --nodes-min 1 --nodes-max 1 --node-volume-size 50	

delete_nodegroup:
	eksctl delete nodegroup --cluster=rajesh-cluster --name=ng-1

describe_cluster:
	eksctl utils describe-stacks --region=us-east-2 --cluster=rajesh-cluster

aws_identity:
	aws sts get-caller-identity

set_context:
	eksctl utils write-kubeconfig --cluster=rajesh-cluster --set-kubeconfig-context=true

# ROLE RELATED

set_aws_auth:
	kubectl apply -f aws_auth.yaml

set_role_mappings:
	kubectl apply -f role_mappings/*

export_aws_auth:
	kubectl get configmap aws-auth -n kube-system  -o yaml > aws_auth.yaml