# bootstrap_k8s_terraform
Kubernetes Cluster bootstrapped via terraform script in AWS, Azure, and GCP. <br>
**The resource tls_private_key is stored unencrypted in state file.**

## Requirements
- Terraform CLI
- Ansible CLI
- Preferred Cloud

## Resources Created

### AWS
- [key pair](./modules/aws/keypair.tf)
- [security groups](./modules/aws/security_group.tf)
  - k8s controller security group
  - worker security groups
- EC2 instances
  - default is 3
    - controller
    - worker1
    - worker2
  - output aws_ssh_commands contains ssh command for each instance
- files
  - generated private key will be saved as ./scripts/{var.key_pair_name}.pem
  - private ips for provisioned instances can be found in ./scripts/nodes.txt

### Azure
- 
- 

### GCP
- 
- 

## Deploy
1. Update terraform.tfvars.
2. terraform plan -var-file=local.tfvars
3. terraform apply -auto-approve -var-file=local.tfvars
