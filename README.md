# bootstrap_k8s_terraform
Kubernetes Cluster bootstrapped via Terraform and Ansible in AWS, Azure, and/or GCP. <br>
**The resource tls_private_key is stored unencrypted in state file. Not for production.**

## Requirements
- Python 3
- Terraform CLI
- Ansible CLI
- Preferred Cloud Credentials

## Deployment Instructions
1. Update [terraform.tfvars](./terraform.tfvars).
   1. `cloud_provider`: provides k8s.py with information to automate commenting of modules
   2. `project_id`: string to be used as an identifier in provisioned cloud resources.
   3. `vm_names`: identifiers for provisioned machines and ansible host names
      1. **NOTE: the first key will be the assumed controller node while creating the inventory file.**
   4. `aws`: required credentials and instance information
      1. Ansible configuration is for AWS Linux 2 images
      2. Kubernetes requires at least 2 cores
   5. `azure`: required credentials, resource group location, network address space, and virtual machine information
      1. Ansible configuration tested on CentOS 8_5
      2. Kubernetes requires at least 2 cores
   6. `gcp`: required credentials, network, and machine data.
      1. Ansible configuration tested on CentOS 8_5
      2. Kubernetes requires at least 2 cores
2. Initialize Terraform project and apply: `python3 k8s.py terraform.tfvars init`
3. Upgrade and apply Terraform changes: `python3 k8s.py terraform.tfvars upgrade`
4. Destroy Terraform project: `python3 k8s.py terraform.tfvars`

## Overview
| **Files**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | **Implementation**                                            |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|
| <code>.<br>├──&nbsp;README<br>├──&nbsp;ansible/<br>│&nbsp;&nbsp;&nbsp;├──&nbsp;inventory.yaml<br>│&nbsp;&nbsp;&nbsp;├──&nbsp;playbook.yaml<br>│&nbsp;&nbsp;&nbsp;└──&nbsp;roles/<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──&nbsp;k8s/<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├──&nbsp;meta/<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;└──&nbsp;main.yaml<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├──&nbsp;tasks/<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;└──&nbsp;main.yaml<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──&nbsp;vars/<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──&nbsp;main.yaml<br>├──&nbsp;ansble.tf<br>├──&nbsp;k8s.py<br>├──&nbsp;locals.tf<br>├──&nbsp;main.tf<br>├──&nbsp;modules/<br>│&nbsp;&nbsp;&nbsp;├──&nbsp;aws/<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;ec2.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;keypair.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;locals.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;outputs.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;security_group.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;└──&nbsp;variables.tf<br>│&nbsp;&nbsp;&nbsp;├──&nbsp;azure/<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;locals.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;network.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;network_security_group.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;outputs.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;resource_group.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;sshkey.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;├──&nbsp;variables.tf<br>│&nbsp;&nbsp;&nbsp;│&nbsp;&nbsp;&nbsp;└──&nbsp;vm.tf<br>│&nbsp;&nbsp;&nbsp;└──&nbsp;gcp/<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├──&nbsp;firewalls.tf<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├──&nbsp;locals.tf<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├──&nbsp;outputs.tf<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├──&nbsp;sshkey.tf<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;├──&nbsp;variables.tf<br>│&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└──&nbsp;vm.tf<br>├──&nbsp;outputs.tf<br>├──&nbsp;providers.tf<br>├──&nbsp;terraform.tfvars<br>├──&nbsp;variables.tf<br>└──&nbsp;versions.tf<br></code> | ![Visual diagram of tools implementation.](./misc/visual.png) |

## Resources Created
- Each cloud provider module used will create:
  - ./ansible/<cloud_provider>_hosts.txt
  - ./ansible/<cloud_provider>_<project/key_pair_name>.pem

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

### Azure
- [resource group](./modules/azure/resource_group.tf)
- [tls_private_key](./modules/azure/sshkey.tf)
- [2 network security groups](./modules/azure/network_security_group.tf)
- [virtual network](./modules/azure/network.tf)
- [virtual machines](./modules/azure/vm.tf)
  - default is 3
    - controller
    - worker1
    - worker2

### GCP
- [tls_private_key](./modules/gcp/sshkey.tf)
- [firewalls](./modules/gcp/firewalls.tf)
- [virtual machines](./modules/gcp/vm.tf)
  - default is 3
    - controller
    - worker1
    - worker2