#!/bin/bash

# Apply sysctl params without reboot
sudo sysctl --system

# disable swap 
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

sudo apt-get update -y && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

sudo lsmod | grep br_netfilter