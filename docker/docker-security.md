# Container Escape
docker run -d --privileged -v /:/mnt/host --name escape --cap-add=ALL --pid=host --userns=host ubuntu tail -f /dev/null
docker exec -it escape bash
ps aux
ls /mnt/host

# Attach debug container
docker run -d --name hello brainupgrade/hello
docker run --entrypoint /bin/bash --rm --pid=container:hello --network=container:hello -it brainupgrade/tshoot