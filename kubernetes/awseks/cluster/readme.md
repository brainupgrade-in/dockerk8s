# Create Cluster
eksctl create cluster -f cluster.yaml

# Associate OIDC provider with the cluster

eksctl utils associate-iam-oidc-provider --cluster=annapurna --region=ap-south-1 --approve

# Create Service Account

Using already created k8s-asg-policy, create the service account

export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')

eksctl create iamserviceaccount --name cluster-autoscaler --namespace kube-system --cluster everest \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" \
    --override-existing-serviceaccounts --region=ap-south-1 --approve 

# Launch auto-scaler

<!-- curl -o autoscaler.yaml https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/kubernetes/awseks/cluster/autoscaler-cluster.yaml

sed -i 's/<YOUR CLUSTER NAME>/annapurna/g' autoscaler-cluster.yaml -->

kubectl apply -f cluster-autoscaler.yaml

# Annotate service account
<!-- kubectl annotate serviceaccount cluster-autoscaler -n kube-system eks.amazonaws.com/role-arn=arn:aws:iam::627377777394:role/autoscaler-klaas1 -->

<!-- kubectl annotate serviceaccount cluster-autoscaler -n kube-system  eks.amazonaws.com/role-arn=arn:aws:iam::627377777394:role/eksctl-everest-cluster-ServiceRole-N5WSPL1K23TG -->

# Test Cluster Autoscaling


# Misc
## Create a role (using aws console) to 
Select Web Identity
Select OIDS provider created earlier and enter audience as sts.amazonaws.com and click next
Choose k8s-asg-policy and name the  role as AmazonEKSClusterAutoscalerRole
Edit the role - Trust Relationship condition to 
system:serviceaccount:kube-system:<iamserviceaccount name>.  Also change the oidc pub to sub

## Print ASG 
aws autoscaling describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='k2']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table

## Get ASG Name

export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='k2']].AutoScalingGroupName" --output text)    

## Update ASG manually

aws autoscaling  update-auto-scaling-group --auto-scaling-group-name ${ASG_NAME} --min-size 1 --desired-capacity 2 --max-size 3

## Create AWS account wide ASG policy for EKS - one time
cat <<EoF > /tmp/k8s-asg-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EoF

aws iam create-policy --policy-name k8s-asg-policy --policy-document file:///tmp/k8s-asg-policy.json    

## To prevent CA from removing nodes where its own pod is running
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler \
    cluster-autoscaler.kubernetes.io/safe-to-evict="false"