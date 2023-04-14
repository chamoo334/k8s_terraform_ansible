#!/bin/bash

# create cluster
init_cluster=$(sudo kubeadm init --pod-network-cidr=192.168.10.0/16)

SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
IFS=$'\n'      # Change IFS to newline char
init_output=( $init_cluster )
IFS=$SAVEIFS

# parse and run commands
for (( i=0; i<${#init_output[@]}; i++ ))
do
    if [[ "${init_output[$i]}" == *"mkdir"* || "${init_output[$i]}" == *"sudo"* ]]; then
        eval "${init_output[$i]}"
    elif [[ "${init_output[$i]}" == *"kubeadm"* ]]; then
        add_node_cmmnd="sudo ${test3[$i]}"
    fi
done

# remove taints
kubectl taint nodes --all node-role.kubernetes.io/master-

# install Calico pod network add-on
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubectl get pods -n kube-system
kubectl get pods --all-namespaces
# kubectl get nodes

