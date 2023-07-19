#!/bin/bash

apt update
apt list | grep kubeadm

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system
sysctl --system
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get update && apt-get install -y containerd
mkdir /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl status containerd.service
swapoff -a
apt-get install -y apt-transport-https

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00
apt-mark hold kubelet kubeadm kubectl
kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.24.0
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu: /home/ubuntu/.kube
kubectl get nodes
kubectl apply -f https://docs.projectcalico.org/archive/v3.25/manifests/calico.yaml
kubectl get nodes
kubeadm token create --print-join-command > /home/ubuntu/join.txt
