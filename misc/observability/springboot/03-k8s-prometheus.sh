#!/bin/bash


user=$1
password=$2
namespace=$3

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: ${namespace}  
  labels:
    app: prometheus
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      - job_name: 'obs-springboot'
        metrics_path: '/actuator/prometheus'
        static_configs:
          - targets: ['obs-springboot:80']          
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: prometheus
  namespace: ${namespace}  
  labels:
    app: prometheus
spec:
  serviceName: "prometheus"
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      securityContext:
        fsGroup: 65534
      initContainers:
        - name: volume-permissions
          image: busybox
          command: ["sh", "-c", "chown -R 65534:65534 /prometheus"]
          volumeMounts:
            - name: prometheus-data
              mountPath: /prometheus    
      containers:
      - name: prometheus
        image: prom/prometheus
        args:
          - "--config.file=/etc/prometheus/prometheus.yml"
          - "--storage.tsdb.path=/prometheus"
          - '--web.enable-admin-api'
          - "--web.enable-lifecycle" 
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus
        - name: prometheus-data
          mountPath: /prometheus
        securityContext:
          runAsUser: 65534      
          runAsGroup: 65534                                
      - name: config-reloader
        image: jimmidyson/configmap-reload
        args:
        - --volume-dir=/etc/prometheus
        - --webhook-url=http://prometheus/-/reload
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus          
      volumes:
        - name: config-volume
          configMap:
            name: prometheus-config
  volumeClaimTemplates:
  - metadata:
      name: prometheus-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: prometheus
  name: prometheus
  namespace: ${namespace}  
spec:
  ports:
  - name: prometheus
    port: 9090
    protocol: TCP
    targetPort: 9090
  - name: node-exporter
    port: 9100
    protocol: TCP
    targetPort: 9100
  selector:
    app: prometheus
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${user}-prom.brainupgrade.in
  namespace: ${namespace}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /\$1
    nginx.ingress.kubernetes.io/use-regex: "true"
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${user}-prom.brainupgrade.in
    secretName: ${user}-prom.brainupgrade.in  
  rules:
  - host: ${user}-prom.brainupgrade.in
    http:
      paths:
      - backend:
          service:
            name: prometheus
            port:
              number: 9090
        path: /?(.*)
        pathType: ImplementationSpecific
EOF