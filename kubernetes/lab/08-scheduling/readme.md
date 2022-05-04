# Taint commands
kubectl get nodes -o json | jq ".items[]|{name:.metadata.name, taints:.spec.taints}"

kubect taint nodes <node-name> release=qa:NoSchedule

kubect taint nodes <node-name> release=qa:NoSchedule-

# Exercise
- kubectl create deployment nginx --image=nginx --replicas=3 --dry-run=client -oyaml > scheduling.yaml
- Ensure that no more than one replica runs on the same host (Use podAntiAffinity)

