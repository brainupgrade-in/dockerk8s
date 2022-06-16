#!/bin/bash

curl https://docs.projectcalico.org/manifests/calico.yaml -O

kubectl apply -f calico.yaml

# alternate
#kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml 
#kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

# flannel
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml