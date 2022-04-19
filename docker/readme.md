# Transport images using TAR
 docker run --name ubuntu -itd ubuntu
 docker exec ubuntu ls
 docker exec ubuntu curl google.com
 docker save ubuntu -o ubuntu-save.tar
 docker load -i ubuntu-save.tar ubuntu-save
 docker images
 docker tag ubuntu ubuntu-save
 docker images
 docker save ubuntu-save -o ubuntu-save.tar
 docker load -i ubuntu-save.tar
 docker images

# Transport containers using TAR 
 docker exec -it ubuntu bash

 Add packages curl wget
  apt-get update && apt-get install curl wget -y

 Export container to tar
 docker export -o ubuntu-wget-curl.tar ubuntu

 Import tar to a image
 docker import ubuntu-wget-curl.tar ubuntu-wget-curl:1.0
 docker images

 Launch container using newly  imported image
 
 docker run -itd --name ubuntu-wget-curl ubuntu-wget-curl:1.0 bash
 
 docker ps
 
 docker exec ubuntu-wget-curl curl google.com

 # Update the ingress

 for i in {1..1}; \
do kubectl patch ingress/lab2202u$i-app.brainupgrade.in -n lab2202u$i --type=json \
  -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value":"docker"},{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value":80}]' ; \
  done
# Install docker-compose
https://docs.docker.com/compose/install/
