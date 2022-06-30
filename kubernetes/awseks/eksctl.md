eksctl create cluster --name k8sadmin --spot --node-type t3a.small --nodes 1 --nodes-min 1 --nodes-max 2 --node-volume-size 20 --version  1.20


eksctl create nodegroup --name  spotnodes --instance-types t3a.medium --node-volume-size 20 --nodes-min 1 --nodes-max 2 --nodes 1 --cluster k8sadmin

eksctl create nodegroup --config-file=cluster.yaml

eksctl create nodegroup --name ng-2 --cluster kyndryl --nodes 1 --node-type t3a.xlarge --spot --nodes-min 1 --nodes-max 2 --node-volume-size 50