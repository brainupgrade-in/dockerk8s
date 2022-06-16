# Troubleshooting  commands

## To check kubelet logs

journalctl -u kubelet
sudo journalctl -xeu kubelet

## Kubelet status
systemctl status kubelet

## kubeadm issue [ERROR CRI]: container runtime is not running
rm /etc/containerd/config.toml
systemctl restart containerd
reinitialize kubeadm

## Re-initializing kubeadm

sudo kubeadm reset
IPADDR=$(wget -qO-  http://checkip.amazonaws.com)

sudo kubeadm init --apiserver-advertise-address=$IPADDR --pod-network-cidr=192.168.0.0/16  --cri-socket /run/containerd/containerd.sock  

## Kubelet config
/var/lib/kubelet/config.yaml

## kubeadm config file
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf

## Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService
sudo -i 
cat > /etc/containerd/config.toml <<EOF
[plugins."io.containerd.grpc.v1.cri"]
  systemd_cgroup = true
EOF
systemctl restart containerd

## Generate join token again
sudo kubeadm token create --print-join-command