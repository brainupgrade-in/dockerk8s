eksctl create cluster --name k8sadmin --spot --node-type t3a.small --nodes 1 --nodes-min 1 --nodes-max 2 --node-volume-size 20 --version  1.20


eksctl create nodegroup --name  spotnodes --instance-types t3a.medium --node-volume-size 20 --nodes-min 1 --nodes-max 2 --nodes 1 --cluster k8sadmin --max-pods-per-node 110

eksctl create nodegroup --config-file=cluster.yaml

eksctl create nodegroup --name ng-1 --cluster k8sbasics --nodes 2 --node-type t3a.xlarge --spot --nodes-min 1 --nodes-max 3 --node-volume-size 20