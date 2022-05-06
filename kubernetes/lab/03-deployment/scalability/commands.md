- Create a deployment to run 2 replicas of nginx:1.17 container. Paste the command / yaml 
- Scale down the replicas to 1.  Show the evidence
- Scale up replicas to 3. Show the evidence
- View the roll out history. Show the output
- Set image to nginx:1.18  Show the evidence
- View the roll out history and paste the output here
- Switch to rollout version 1 and show the evidence
- Scale down replicas to 5 and paste the output
- Update image to nginx:1.18 and immediately try another rollout with nginx:1.17  Write your observations here
- Autoscale pod to max 5 min 1 and show the output of hpa resource (k get hpa ...)


- Docker image pull secret
kubectl create secret docker-registry regcred \
  --docker-username=tiger \
  --docker-password=pass113 \
  --docker-email=tiger@acme.com

  k set resources deploy/hello --limits=cpu=0.01,memory=50Mi --requests=cpu=0.01,memory=50Mi

  # Load Testing command
for i in {1..1000000};do echo hello; done | xargs -P100 -n 1 curl
while true;do curl hello;echo $(date);sleep 0.01s;done