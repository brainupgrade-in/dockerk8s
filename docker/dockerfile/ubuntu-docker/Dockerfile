FROM ubuntu
LABEL maintainer "info@brainupgrade.in"

RUN apt-get update && apt-get install -y curl wget apt-transport-https ca-certificates curl software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"


# install docker cli
RUN mkdir -p /tmp/_install && cd /tmp/_install && wget https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz  && tar -xvzf docker-latest.tgz && cd docker && cp docker /usr/bin/docker && rm -rf  /tmp/_install
RUN chmod +x /usr/bin/docker

# add ubuntu to docker group 
RUN groupadd -g 999 docker
# RUN usermod -a -G docker ubuntu
#ENTRYPOINT ["tail","-f","/dev/null"]

# docker build -t ubuntu-docker .
# docker run -d -t  ubuntu-docker
# docker run -d ubuntu tail -f /dev/null
# docker run -d ubuntu sleep infinity