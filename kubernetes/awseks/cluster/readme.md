# To check autoscaling groups
aws autoscaling describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='rajesh-cluster']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table

export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='rajesh-cluster']].AutoScalingGroupName" --output text)    

# To update ASG if required
aws autoscaling  update-auto-scaling-group --auto-scaling-group-name ${ASG_NAME} --min-size 1 --desired-capacity 1 --max-size 4


# Setting up ASG policy - Done by Super Admin 
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


# Setup Access
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')

eksctl utils associate-iam-oidc-provider --cluster rajesh-cluster --approve

eksctl create iamserviceaccount --name cluster-autoscaler-rajesh --namespace kube-system --cluster rajesh-cluster \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" --approve 


kubectl apply -f cluster-autoscaler.yaml

# To prevent CA from removing nodes where its own pod is running
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler \
    cluster-autoscaler.kubernetes.io/safe-to-evict="false"