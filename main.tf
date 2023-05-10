#! Create Kubernetes cluster in AWS
module "aws_k8s" {
 count                     = var.cloud_provider.aws ? 1 : 0
 source                    = "./modules/aws"
 ami_id                    = var.aws.ami_id
 ec2_names                 = var.vm_names
 instance_type             = var.aws.instance_type
 key_pair_name             = var.project_id
 sg_name_prefix            = var.project_id
 sg_k8s_controller_ingress = var.sg_controller
 sg_k8s_worker_ingress     = var.sg_worker
}

#! Create Kubernetes cluster in Azure
module "azure_k8s" {
 count                           = var.cloud_provider.azure ? 1 : 0
 source                          = "./modules/azure"
 resource_group_name             = var.project_id
 resource_group_location         = var.azure.resource_group_location
 ssh_key_name                    = var.project_id
 network_name                    = var.project_id
 network_address_space           = var.azure.address_space
 vm_names                        = var.vm_names
 sg_k8s_controller               = local.azure_sg.controller
 sg_k8s_worker                   = local.azure_sg.worker
 vm_size                         = var.azure.vm_size
 admin_username                  = var.azure.admin_username
 disable_password_authentication = var.azure.disable_password_authentication
 source_image                    = var.azure.source_image
}

#! Create Kubernetes cluster in GCP
module "gcp_k8s" {
  count        = var.cloud_provider.gcp ? 1 : 0
  source       = "./modules/gcp"
  vm_names     = var.vm_names
  ssh_key_name = var.project_id
  network      = var.gcp.network
  machine_type = var.gcp.machine_type
  image        = var.gcp.image
  admin_username = var.gcp.admin_username
  firewalls    = local.gcp_firewall
}

#! Create Ansible playbook
resource "local_file" "playbook" {
  filename = "./ansible/playbook.yaml"
  content  = <<-EOT
%{if var.cloud_provider.aws}
- name: Create AWS Kubernetes clusters
  hosts: aws
  gather_facts: no
  remote_user: root
  become: yes
  roles:
    - ./roles/aws%{endif}
%{if var.cloud_provider.azure}
- name: Create Azure Kubernetes clusters
  hosts: azure
  gather_facts: no
  remote_user: root
  become: yes
  roles:
    - ./roles/azure%{endif}
%{if var.cloud_provider.gcp}
- name: Create GCP Kubernetes clusters
  hosts: gcp
  gather_facts: no
  remote_user: ${var.gcp.admin_username}
  become: yes
  roles:
    - ./roles/gcp%{endif}
EOT
}

#! Create Ansible inventory
resource "local_file" "inventory" {
  filename = "./ansible/inventory.yaml"
  content  = <<-EOT
all:
  children:
EOT
}

#! Add AWS inventory
resource "null_resource" "aws_inventory" {
  count                           = var.cloud_provider.aws ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ${local_file.inventory.filename}
    aws:
      vars:
        ansible_port: 22
        ansible_user: ec2-user
        ansible_ssh_private_key_file: ${module.aws_k8s[0].private_key_file}
      hosts:
        aws_controller:
          ansible_host: ${module.aws_k8s[0].controller_public_ip}
      children:
        aws_workers:
          hosts:%{for node in module.aws_k8s[0].workers}
            aws_${node}:
              ansible_host: ${module.aws_k8s[0].worker_public_ips[node]}%{endfor}
EOF
EOT
  }

  depends_on = [module.aws_k8s, local_file.inventory]
}

#! Add Azure inventory
resource "null_resource" "azure_inventory" {
  count                           = var.cloud_provider.azure ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ${local_file.inventory.filename}
    azure:
      vars:
        ansible_port: 22
        ansible_user: ${var.azure.admin_username}
        ansible_ssh_private_key_file: ${module.azure_k8s[0].private_key_file}
      hosts:
        azure_controller:
          ansible_host: ${module.azure_k8s[0].controller_public_ip}
      children:
        azure_workers:
          hosts:%{for node in module.azure_k8s[0].workers}
            azure_${node}:
              ansible_host: ${module.azure_k8s[0].worker_public_ips[node]}%{endfor}
EOF
EOT
  }

  depends_on = [module.azure_k8s, local_file.inventory]
}

#! Add GCP inventory
resource "null_resource" "gcp_inventory" {
  count                           = var.cloud_provider.gcp ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ${local_file.inventory.filename}
    gcp:
      vars:
        ansible_port: 22
        ansible_user: ${var.gcp.admin_username}
        ansible_ssh_private_key_file: ${module.gcp_k8s[0].private_key_file}
      hosts:
        gcp_controller:
          ansible_host: ${module.gcp_k8s[0].controller_public_ip}
      children:
        gcp_workers:
          hosts:%{for node in module.gcp_k8s[0].workers}
            gcp_${node}:
              ansible_host: ${module.gcp_k8s[0].worker_public_ips[node]}%{endfor}
EOF
EOT
  }

  depends_on = [module.gcp_k8s, local_file.inventory]
}

resource "null_resource" "clean_up" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
if test -f ./ansible/inventory.yaml; then rm ./ansible/inventory.yaml; fi
if test -f ./ansible/plays.log; then rm ./ansible/plays.log; fi
EOT
  }
}