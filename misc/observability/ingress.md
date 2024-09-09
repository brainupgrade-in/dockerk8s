htpasswd -c auth -u mtvlabk8s

kubectl create secret generic cass-basic-auth -n elasticsearch --from-file=auth

kubectl create ingress kibana -n elasticsearch --rule="mtvlabk8s-kibana.gheware.com/?(.*)=kibana:5601,tls=kscr8kibna" --class webapprouting.kubernetes.azure.com --annotation cert-manager.io/cluster-issuer=letsencrypt-prod --annotation nginx.ingress.kubernetes.io/rewrite-target=/$1 --annotation nginx.ingress.kubernetes.io/use-regex="true" --annotation nginx.ingress.kubernetes.io/auth-type=basic --annotation nginx.ingress.kubernetes.io/auth-secret=cass-basic-auth

kubectl create ingress grafana -n monitoring --rule="mtvlabk8s-grafana.gheware.com/?(.*)=grafana:80,tls=kscr8grfbna" --class webapprouting.kubernetes.azure.com --annotation cert-manager.io/cluster-issuer=letsencrypt-prod --annotation nginx.ingress.kubernetes.io/rewrite-target=/$1 --annotation nginx.ingress.kubernetes.io/use-regex="true"

kubectl create ingress weather -n weather --rule="mtvlabk8s-weather.gheware.com/?(.*)=weather-front:80,tls=kscr8weatr" --class webapprouting.kubernetes.azure.com --annotation cert-manager.io/cluster-issuer=letsencrypt-prod --annotation nginx.ingress.kubernetes.io/rewrite-target=/$1 --annotation nginx.ingress.kubernetes.io/use-regex="true"

kubectl create ingress jenkins --rule="mtvlabk8s-jenkins.gheware.com/?(.*)=jenkins:80,tls=kscr8nkins" --class webapprouting.kubernetes.azure.com --annotation cert-manager.io/cluster-issuer=letsencrypt-prod --annotation nginx.ingress.kubernetes.io/rewrite-target=/\$1 --annotation nginx.ingress.kubernetes.io/use-regex="true"