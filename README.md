# bootstrap_k8s_terraform
Kubernetes Cluster bootstrapped via terraform script in AWS, Azure, and GCP. <br>
**The resource tls_private_key is stored unencrypted in state file.**

## Requirements
- Terraform CLI
- Ansible CLI
- Preferred Cloud Credentials

## Resources Created

### Local files
- ./ansible/inventory.yaml
- ./ansible/playbook.yaml

### AWS
- [key pair](./modules/aws/keypair.tf)
- [security groups](./modules/aws/security_group.tf)
  - k8s controller security group (var.sg_k8s_controller_ingress)
  - worker security groups (var.sg_k8s_worker_ingress)
- [EC2 instances](./modules/aws/ec2.tf)
  - default is 3
    - controller
    - worker1
    - worker2
  - output aws_ssh_commands contains ssh command for each instance
  - **NOTE: the first key will be the assumed controller node while creating the inventory file. View code [here](./modules/aws/ansible.tf).**
- Terraform creates and destroys files for use with Ansible. *These files will be destroyed along with other Terraform resources.*
  - ./ansible/aws_{var.key_pair_name}.pem
  - ./ansible/aws_hosts.txt

### Azure
- [resource group]()
- [2 network security groups](./modules/azure/network_security_group.tf)
- [virtual network](./modules/azure/network.tf)
- [virtual machines]()
  - default is 3
    - controller
    - worker1
    - worker2
  - output azure_ssh_commands contains ssh command for each instance
  - **NOTE: the first key will be the assumed controller node while creating the inventory file. View code [here](./modules/aws/ansible.tf).**
- Terraform creates and destroys files for use with Ansible. *These files will be destroyed along with other Terraform resources.*
  - ./ansible/azure_{var.key_pair_name}.pem
  - ./ansible/azure_hosts.txt

### GCP
- 
- 

## Deployment Instructions
1. Update terraform.tfvars.
   1. 
2. terraform init -upgrade
3. terraform plan -var-file=local.tfvars
4. terraform apply -auto-approve -var-file=local.tfvars
5. export ANSIBLE_ROLES_PATH=./ansible/roles
6. ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml
7. terraform destroy -auto-approve -var-file=local.tfvars
8. unset ANSIBLE_ROLES_PATH
