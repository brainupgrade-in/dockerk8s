# Backend - mysql cluster using statefulset

k config set-context --current --namespace weather
kubectl apply -f https://k8s.io/examples/application/mysql/mysql-configmap.yaml
kubectl apply -f https://k8s.io/examples/application/mysql/mysql-services.yaml
kubectl apply -f https://k8s.io/examples/application/mysql/mysql-statefulset.yaml
kubectl get pods -l app=mysql --watch

kubectl run mysql-client --image=mysql:5.7 -i --rm --restart=Never --\
  mysql -h mysql-0.mysql <<EOF
CREATE DATABASE test;
CREATE TABLE test.messages (message VARCHAR(250));
INSERT INTO test.messages VALUES ('hello');
EOF

kubectl run mysql-client --image=mysql:5.7 -i -t --rm --restart=Never --\
  mysql -h mysql-read -e "SELECT * FROM test.messages"
  
kubectl run mysql-client-loop --image=mysql:5.7 -i -t --rm --restart=Never --\
  bash -ic "while sleep 1; do mysql -h mysql-read -e 'SELECT @@server_id,NOW()'; done"  

