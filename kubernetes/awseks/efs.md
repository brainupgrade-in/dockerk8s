# Deploy EFS driver and Storage Class

kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.3"

cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: <aws-efs-fs-id>
  directoryPerms: "700"
  gidRangeStart: "1000" # optional
  gidRangeEnd: "2000" # optional
  basePath: "/dynamic_provisioning" # optional
EOF  

Ref: https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes/dynamic_provisioning

# IAM role & policy


curl -o iam-policy-example.json https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json

aws iam create-policy \
    --policy-name AmazonEKS_EFS_CSI_Driver_Policy \
    --policy-document file://iam-policy-example.json

aws eks describe-cluster --name microk8s --query "cluster.identity.oidc.issuer" --output text    

Output: https://oidc.eks.ap-south-1.amazonaws.com/id/<oidc-id>

Create this file: trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<aws-account-id>:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/<oidc-id>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.ap-south-1.amazonaws.com/id/<oidc-id>:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }
  ]
}

aws iam create-role \
  --role-name AmazonEKS_EFS_CSI_DriverRole \
  --assume-role-policy-document file://"trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::<aws-account-id>:policy/AmazonEKS_EFS_CSI_Driver_Policy \
  --role-name AmazonEKS_EFS_CSI_DriverRole

Ref: https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html

# EKS Service account

eksctl create iamserviceaccount \
    --cluster <cluster-name> \
    --namespace kube-system \
    --name efs-csi-controller-sa \
    --attach-policy-arn arn:aws:iam::<aws-account-id>:policy/AmazonEKS_EFS_CSI_Driver_Policy \
    --approve \
    --region ap-south-1    

## SA Annotation - Add if not added by above command 
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: aws-efs-csi-driver
  name: efs-csi-controller-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<aws-account-id>:role/AmazonEKS_EFS_CSI_DriverRole    

# Restart EFS CSI Controller
kubectl rollout restart deploy efs-csi-controller -n kube-system

# Security Group - Inbound rule
Allow access to port 2049 from cluster CIDR to aws efs sg            