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

# Volume Commands
## Docker root space
docker run -d --name devtest --mount source=app,target=/app nginx
## Persist data on host
- docker run -d -it --mount type=bind,source=/shared,target=/app nginx
- docker run -d -it --mount type=bind,source=/shared,target=/app,readonly nginx
## Persist data in memory
docker run -d --restart always -it --name tmptest --mount type=tmpfs,destination=/app nginx

## Simplied commands
- docker run -d -p 5000:5000 -v docker_registry:/var/lib/registry registry:2
- docker run -d -p 5000:5000 -v /shared/docker_registry:/var/lib/registry registry:2

# Install docker-compose
https://docs.docker.com/compose/install/
