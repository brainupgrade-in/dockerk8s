# Microservices - Global Bank

Sample Global Bank System demonstrated through a set of microservices

User Interface of Global Bank is presented to its Customers and employees via the microservice Frontend

Frontend depends on Authentication microservice to authenticate its bank's users.
Once the user logs in, based on the role he/she is shown appropriate UI pages.
When employee logs in, customer details are shown. To view accounts, click on the customer you are interested in.

To know the transactions,  click on the respective customer account.

![Overview](assets/microservices-case-study.png)

## List of microservices

- **Frontend** - UI of the Global Bank Application
- **Authentication** - Microservice to provide Authentication REST API
- **Customer** - Microservice to provide Customer REST API
- **Account** - Microservice to provide Account REST API
- **Transaction** - Microservice to provide Transaction REST API
- **Rules** - Microservice to provide Rules REST API

## Build & Run locally

To build the app, get the source code and dev env by running below command

`kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/global-bank-dev.yaml`

Enter into the Dev environment using below command

`kubectl exec -it deploy/global-bank-dev -- bash`

Build & launch the microservices

```
cd /app/global-bank-authentication/ && mvn clean package && java -jar target/authentication.jar &
cd /app/global-bank-rules/ && mvn clean package && java -jar target/rules.jar &
cd /app/global-bank-customer/ && mvn clean package && java -jar target/customer.jar &
cd /app/global-bank-account/ && mvn clean package && java -jar target/account.jar &
cd /app/global-bank-transaction/ && mvn clean package && java -jar target/transaction.jar &
cd /app/global-bank-frontend/ && git pull origin main && npm start
```

# Verify

Get the HOST using below command and access it using the browser

`kubectl get ingress`

# Dockerization

Every microservice, contains Dockerfile which is used to build the microservice.  It takes care of launching dependent build tools as docker container itself and then once code is built, and then in a separate image the app is containerized thus making the final image as small as possible at the same time removing the burden on setting up build environment for any of the technologies used by the respective microservice.
You can give the image name as you deem appropriate and if you did then update k8s.yaml accordingly.

# Deploy on Kubernetes

Run below commands in your cluster

```
kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/01a-authentication-db.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/03a-customer-db.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/04a-account-db.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/05a-transaction-db.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/01b-authentication.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/02-rules.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/03b-customer.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/04b-account.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/05b-transaction.yaml

kubectl apply -f https://raw.githubusercontent.com/brainupgrade-in/dockerk8s/main/app/global-bank/06-frontend.yaml

```
