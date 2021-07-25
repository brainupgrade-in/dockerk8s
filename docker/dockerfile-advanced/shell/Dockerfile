FROM ubuntu
ENTRYPOINT top -b
CMD top --param1

# docker build -t epshell .
# docker run -itd --rm --name test epshell 
# docker exec test ps aux
# Observation: CMD inputs are appended in shell form

# docker run -itd --rm --name test epshell --param2
# docker exec test ps aux
# Observation: CMD inputs are suppressed and container run arguments are appended
