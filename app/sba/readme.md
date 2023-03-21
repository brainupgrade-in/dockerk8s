# Simple deployment steps
## API server
kubectl create deploy apiserver --image brainupgrade/sba-apiserver:hsql
kubectl expose deploy apiserver --port 80 --target-port 8080
## Frontend
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/sba-front/nginx/k8s.yaml
## Ingress - Update
Update ingress with the service name sba-frontend

# Improvements
## Frontend

- Nginx is used to serve frontend Ref: https://github.com/brainupgrade-in/sba-front/blob/nginx/Dockerfile-nginx
- All calls made to API Server (backend) are proxied through Nginx instead of the code running in the browser making calls to Backend (serious security concern + operational burden of  making API server accessible over the internet) (Ref https://github.com/brainupgrade-in/sba-front/blob/nginx/k8s.yaml)
- Defined API_URL such that Nginx can proxy request to backend app via Kubernets service (Ref https://github.com/brainupgrade-in/sba-front/blob/nginx/src/Constants.js)
