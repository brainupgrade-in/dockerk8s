#  User Commands
- kubectl run hello --image=brainupgrade/hello --port=80
- kubectl get pods -owide
- kubectl describe pod hello
- kubectl run -it busybox --image=busybox --restart=Never
- kubectl run tutum --image tutum/hello-world
- kubectl run nginx --image=nginx
- kubectl describe pod/nginx 
- kubectl delete pod nginx 
- kubectl run test --image brainupgrade/tshoot
- kubectl exec -it test -- bash
- kubectl get all 
- kubectl get pods -oyaml 
- kubectl get pods --sort-by=.metadata.name 
- kubectl describe pods 
- kubectl get pod/< pod-name > 
- kubectl get pod -l < labe-name >=< label-value > 
- kubectl delete pods --all 
- kubectl get pods -ojson | jq '.items[]|{name:.metadata.name}' 

# Admin Commands
- kubectl get nodes -ojson | jq '.items[] | {name:.metadata.name, cap:.status.capacity}'
- kubectl get nodes -oyaml | egrep '\sname:|cpu:|memory:' 
- kubectl cluster-info