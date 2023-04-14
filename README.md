# bootstrap_k8s_terraform
Kubernetes Cluster bootstrapped via terraform script in AWS, Azure, and GCP. <br>
**The resource tls_private_key is stored unencrypted in state file.**

## Resources Created

### AWS
- key pair (tls_private_key)
- 3 EC2 instances

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
