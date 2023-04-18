# bootstrap_k8s_terraform
Kubernetes Cluster bootstrapped via terraform script in AWS, Azure, and GCP. <br>
**The resource tls_private_key is stored unencrypted in state file.**

## Requirements
- Terraform CLI
- Ansible CLI
- Preferred Cloud Credentials

## Cloud Resources Created

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
- Files for AWS cluster can be found in ./scripts/aws
  - ./scripts/aws/{var.key_pair_name}.pem
  - ./scripts/hosts.txt
  - all_nodes.sh
    - updated with host private ips from hosts.txt and removed when cluster is deleted
  - controller_node.sh
  - worker_node.sh

### Azure
- 
- 

### GCP
- 
- 

## Deployment Instructions
1. Update terraform.tfvars.
2. terraform plan
3. terraform apply -auto-approve
