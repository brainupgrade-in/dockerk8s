#!/bin/bash

curl https://docs.projectcalico.org/manifests/calico.yaml -O

kubectl apply -f calico.yaml