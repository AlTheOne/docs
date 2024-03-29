#!/bin/bash

# Description:  Primary install k8s
# OS:           Ubuntu 20.04
# Version:      0.1
# Telegram:     @AlTheOne @gYaqubi

# Upload to server...
# scp k8s_install.bash USERNAME@IP:~
# chmod +x k8s_install.bash

set -e

echo "########################################"
echo "## Update OS"
echo "########################################"

sudo apt update && echo y | sudo apt upgrade


echo "########################################"
echo "## Install additional tools"
echo "########################################"

sudo apt install -y htop mc micro curl


echo "########################################"
echo "## Swap OFF"
echo "########################################"
sudo swapoff -a

echo "########################################"
echo "## Install & Activate Docker.IO"
echo "########################################"

echo y | sudo apt install docker.io

sudo systemctl enable docker
sudo systemctl start docker

cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

sudo systemctl restart docker.service


echo "########################################"
echo "## Install addtional tools for OS"
echo "########################################"

sudo apt -y install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update


echo "########################################"
echo "## Update OS Hostname"
echo "########################################"

sudo hostnamectl set-hostname kubernetes-master


echo "########################################"
echo "## Install Kubernetes"
echo "########################################"

echo y | sudo apt install kubeadm kubelet kubectl


echo "########################################"
echo "## Init k8s cluster"
echo "########################################"

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
