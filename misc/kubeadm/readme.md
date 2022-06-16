# Troubleshooting  commands

## To check kubelet logs

journalctl -u kubelet
sudo journalctl -xeu kubelet

## Kubelet status
systemctl status kubelet

## kubeadm issue [ERROR CRI]: container runtime is not running
rm /etc/containerd/config.toml
systemctl restart containerd
kubeadm init

## Re-initializing kubeadm

sudo kubeadm reset
IPADDR=$(wget -qO-  http://checkip.amazonaws.com)

NODENAME=$(hostname -s)

sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=192.168.0.0/16 --node-name $NODENAME --ignore-preflight-errors Swap
