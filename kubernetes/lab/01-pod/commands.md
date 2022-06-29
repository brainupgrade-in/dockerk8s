#  User Commands
- kubectl get pods 
- kubectl run hello-world --image=tutum/hello-world --port=80
- kubectl describe pod hello-world 
- kubectl run -it busybox --image=busybox --restart=Never
- kubectl describe pod/nginx 
- kubectl run nginx --image=nginx
- kubectl delete pod nginx 
- kubectl get all 
- kubectl get pods -oyaml 
- kubectl get services -ojson 
- kubectl get pods --sort-by=.metadata.name 
- kubectl get rs,deployments,service 
- kubectl describe pods - kubectl get pod/<pod-name> svc/<svc-name> 
- kubectl get pod -l <labe-name>=<label-value> 
- kubectl delete pods --all 
- kubectl get pods -ojson | jq '.items[]|{name:.metadata.name}' 

# Admin Commands
- kubectl get nodes -ojson | jq '.items[] | {name:.metadata.name, cap:.status.capacity}'
- kubectl get nodes -oyaml | egrep '\sname:|cpu:|memory:' 
- kubectl cluster-info