k create deploy postgres   --image postgres
k set env deploy postgres --env POSTGRES_USER=postgres --env POSTGRES_PASSWORD=postgres --env POSTGRES_DB=app
k expose deploy postgres --port 5432 --target-port 5432

k create deploy apiserver --image brainupgrade/sba-apiserver:1.0.0
k set env deploy apiserver --env spring.datasource.url=jdbc:postgresql://postgres:5432/app
k expose deploy apiserver --port 80 --target-port 8080

k create deploy frontend --image brainupgrade/sba-frontend:base
k set env deploy frontend --env REACT_APP_API_URL=https://<your-domain>/api/
k expose deploy frontend --port 80 --target-port 3000

# SQS Integration
k create deploy apiserver --image brainupgrade/sba-apiserver:2.0.0-metrics-sqs
k set env deploy apiserver --env cloud.aws.region.static=ap-south-1 --env cloud.aws.credentials.access-key=  --env cloud.aws.credentials.secret-key=

k create ingress app --rule=" <URL> /?(.*)=app:80,tls=sba" --class nginx --annotation=cert-manager.io/cluster-issuer=letsencrypt-prod --annotation=nginx.ingress.kubernetes.io/rewrite-target=/\$1