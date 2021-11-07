#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.17.17.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[TASK 3] Deploy Calico network"
wget -O /root/calico.yaml https://docs.projectcalico.org/manifests/calico.yaml --no-check-certificate
vim -c "%s/docker.io/quay.io/g" -c "wq" /root/calico.yaml

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK 5] Copy Kubeconfig File and Install Calico"
mkdir /root/.kube
cp -rvf /etc/kubernetes/admin.conf /root/.kube/config
kubectl create -f /root/calico.yaml

echo "[TASK 6] Deploy Load Balancer"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
cat >>config.yml<<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.17.17.110-172.17.17.120
EOF
kubectl create -f config.yml

echo "[TASK 7] Deploy NGINX Ingress Controller"
apt-get install git -y
git clone https://github.com/kubernetes/ingress-nginx
cd ingress-nginx/deploy/static/provider/cloud
kubectl create -f deploy.yaml
