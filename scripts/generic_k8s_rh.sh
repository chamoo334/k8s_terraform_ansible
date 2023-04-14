#!/bin/bash
controller=false
add_node_cmmnd=""

all_nodes () {
# update, disable swap and SELinux 
sudo yum update -y
sudo swapoff -a
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# configure networking

sudo yum install -y iproute-tc

# enable kernel modules for container runtime
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

## install container Runtime
export VERSION=1.26

sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/CentOS_8/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo

sudo yum install cri-o -y
sudo systemctl enable crio
sudo systemctl start crio

## install kubeadm, kubelet, and kubectl
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y kubelet-1.26.1 kubeadm-1.26.1 kubectl-1.26.1 --disableexcludes=kubernetes
sudo systemctl enable kubelet
sudo systemctl start kubelet
}

controller (){
# create cluster
init_cluster=$(sudo kubeadm init --pod-network-cidr=192.168.10.0/16)

SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
init_output=( $init_cluster )
IFS=$SAVEIFS

for (( i=0; i<${#init_output[@]}; i++ ))
do
    if [[ "${init_output[$i]}" == *"mkdir"* || "${init_output[$i]}" == *"sudo"* ]]; then
        eval "${init_output[$i]}"
    elif [[ "${init_output[$i]}" == *"kubeadm"* ]]; then
        add_node_cmmnd="sudo ${test3[$i]}"
    fi
done

# configure .kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# remove taints
kubectl taint nodes --all node-role.kubernetes.io/master-

# install Calico pod network add-on
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubectl get pods -n kube-system
kubectl get pods --all-namespaces
}

worker (){
## add node to cluster
eval "${add_node_cmmnd}"
}

all_nodes

if [ $controller = true ]; then
controller
else
worker
fi