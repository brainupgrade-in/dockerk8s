# Apps

kubectl create deploy hello --image brainupgrade/hello:1.0
kubectl expose deploy hello --port 80 --target-port 8080
kubectl create deploy hellov2 --image brainupgrade/hello:2.0
kubectl expose deploy hellov2 --port 80 --target-port 8080
kubectl create deploy weather --image brainupgrade/weather:monolith
kubectl expose deploy weather --port 80 --target-port 8080
kubectl create deploy logger --image brainupgrade/request-logger
kubectl expose deploy logger --port 80 --target-port 8080


