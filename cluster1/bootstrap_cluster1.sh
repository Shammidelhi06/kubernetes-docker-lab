#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[TASK 3] Deploy Calico network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK 5] Copy Kubeconfig File"
cp /etc/kubernetes/admin.conf /root/.kube/config

echo "[TASK 6] Create Kubernetes Resources"
kubectl create namespace app-team1
kubectl create ns internal
kubectl create sa default -n internal
kubectl create sa default -n app-team1
kubectl run test80 --image=quay.io/gauravkumar9130/nginx -n internal
kubectl expose pod test80 --target-port=80 --port=80 -n internal
kubectl run test9000 --image=quay.io/gauravkumar9130/nginx -n internal
kubectl expose pod test9000 --target-port=80 --port=9000 -n internal
kubectl create deployment front-end --image=quay.io/gauravkumar9130/nginx --replicas=2
kubectl create namespace ing-internal
kubectl create sa default -n ing-internal
kubectl create deployment hi-app --image=quay.io/gauravkumar9130/hi --replicas=4 -n ing-internal
kubectl expose deployment hi-app --target-port=80 --port=5678 -n ing-internal
git clone https://github.com/kubernetes/ingress-nginx
cd ingress-nginx/deploy/static/provider/cloud
kubectl create -f deploy.yaml
kubectl create deployment loadbalancer --image=quay.io/gauravkumar9130/nginx
cat >>datavol.yml<<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-volume
spec:
  storageClassName: csi-hostpath-sc
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
EOF
kubectl apply -f datavol.yml
cat >>foobar.yml<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: foobar
spec:
  containers:
  - name: foobar
    image: quay.io/gauravkumar9130/busybox
    args: [/bin/sh, -c,
            'i=0; while true; do echo "unable-to-access-website"; i=1; sleep 10000; done']
EOF
kubectl apply -f foobar.yml
cat >>legacy.yml<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: legacy-app
spec:
  containers:
  - name: legacy-app
    image: quay.io/gauravkumar9130/legacy
    args: [/bin/sh, -c,
            'i=0; while true; do echo "Welcome to legacy-app" >> /var/log/legacy-app.log; i=1; sleep 10000; done']
EOF
kubectl apply -f legacy.yml
git clone https://github.com/gauravkumar9130/metrics-server.git
cd metrics-server
kubectl create -f .
