# Github 
Project https://github.com/brainupgrade-in/request-logger/

# Launch Jenkins using docker 
docker run --name jenkins -u 0 -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):$(which docker) jenkins/jenkins:lts

# Github Steps
Github Create token  https://github.com/settings/tokens/new  and use this token to create jenkins credentials named github-bu-token 
Github repo hook  https://rajesh.brainupgrade.in/ghprbhook/ so that pull requests can be sent to jenkins

# Jenkins Steps
## Settings 
### Global credentials  
docker-hub-credentials  (docker hub credentials)
(Github bu token)
### Plugins
Embeddable Build Status Plugin
Github Pull request builder
github integration plugin
## Job
Crete job - Pipeline for project https://github.com/brainupgrade-in/request-logger/ 
Enable Build Trigger (GHPR) & Enter Github project URL (General) 