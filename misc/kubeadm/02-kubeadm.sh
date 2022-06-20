#!/bin/bash

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
#sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-get install -y kubelet=1.20.6-00 kubectl=1.20.6-00 kubeadm=1.20.6-00

sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet

IPADDR=$(wget -qO-  http://checkip.amazonaws.com)

sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
#sudo kubeadm init  --pod-network-cidr=192.168.0.0/16  
sudo systemctl start kubelet

#sudo kubeadm init --apiserver-advertise-address=$IPADDR --pod-network-cidr=192.168.0.0/16  --cri-socket /run/containerd/containerd.sock  
#sudo kubeadm init  --pod-network-cidr=192.168.0.0/16  

#mkdir -p $HOME/.kube
#sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubeadm join 172.31.24.140:6443 --token 920fmu.lg211n55lv4m5c8l \
    --discovery-token-ca-cert-hash sha256:d2a54f8ac04f36f067cf15f4a7233d9e90614e29ed7b404ddf4fbc3cc057735d