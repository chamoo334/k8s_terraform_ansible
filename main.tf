# Create Kubernetes cluster in AWS
# module "aws_k8s" {
#   count                     = var.cloud_provider.aws ? 1 : 0
#   source                    = "./modules/aws"
#   ami_id                    = var.ami_id
#   ec2_names                 = var.vm_names
#   instance_type             = var.instance_type
#   key_pair_name             = var.project_id
#   sg_name_prefix            = var.project_id
#   sg_k8s_controller_ingress = var.aws_controller_ingress
#   sg_k8s_worker_ingress     = var.aws_worker_ingress
# }

# Create Kubernetes cluster in Azure
module "azure_k8s" {
  count                   = var.cloud_provider.azure ? 1 : 0
  source                  = "./modules/azure"
  resource_group_name     = var.project_id
  resource_group_location = var.resource_group_location
  ssh_key_name            = var.project_id
  network_name = var.project_id
  network_address_space = var.azure_address_space
  vm_names = var.vm_names
  sg_k8s_controller = var.azure_controller_sg
  sg_k8s_worker = var.azure_worker_sg
}

# Create Kubernetes cluster in GCP
# module "gcp_k8s" {
#     count = var.cloud_provider.gcp ? 1 : 0
#     source = "./modules/gcp"
# }

# Create Ansible playbook
# resource "local_file" "playbook" {
#   filename = "./ansible/playbook.yaml"
#   content  = <<-EOT
# %{if var.cloud_provider.aws}
# - name: Create AWS Kubernetes clusters
#   hosts: aws
#   gather_facts: no
#   remote_user: root
#   become: yes
#   roles:
#     - aws%{endif}
# %{if var.cloud_provider.azure}
# - name: Create Azure Kubernetes clusters
#   hosts: azure
#   gather_facts: no
#   remote_user: root
#   become: yes
#   roles:
#     - azure%{endif}
# %{if var.cloud_provider.gcp}
# - name: Create GCP Kubernetes clusters
#   hosts: gcp
#   gather_facts: no
#   remote_user: root
#   become: yes
#   roles:
#     - gcp%{endif}
# EOT
# }

# # Create Ansible inventory
# resource "local_file" "inventory" {
#   filename = "./ansible/inventory.yaml"
#   content  = <<-EOT
# all:
#   children: %{if var.cloud_provider.aws}
#     aws:
#       vars:
#         ansible_port: 22
#         ansible_user: ec2-user
#         ansible_ssh_private_key_file: ${module.aws_k8s[0].aws_private_key_file}
#       hosts:
#         aws_controller:
#           ansible_host: ${module.aws_k8s[0].aws_controller_public_ip}
#       children:
#         aws_workers:
#           hosts:%{for node in module.aws_k8s[0].aws_workers}
#             aws_${node}:
#               ansible_host: ${module.aws_k8s[0].aws_worker_public_ips[node]}%{endfor}%{endif}%{if var.cloud_provider.azure}
#     azure:%{endif}%{if var.cloud_provider.gcp}
#     gcp:%{endif}
# EOT

#   depends_on = [module.aws_k8s]
# }

# Set Ansible roles path and run created playbook with created inventory
# resource "null_resource" "run_playbook" {
#   #     provisioner "local-exec" {
#   #         command = <<-EOT
#   # export ANSIBLE_ROLES_PATH=./ansible/roles
#   # ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml -T 720 > ./ansible/plays.log
#   # EOT
#   #     }

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<-EOT
# unset ANSIBLE_ROLES_PATH
# if test -f ./ansible/inventory.yaml; then rm ./ansible/inventory.yaml; fi
# if test -f ./ansible/plays.log; then rm ./ansible/plays.log; fi
# EOT
#   }

#   depends_on = [local_file.inventory, local_file.playbook, module.aws_k8s]
#   # depends_on = [local_file.inventory, local_file.playbook, module.aws_k8s.null_resource.aws_inventory, module.aws_k8s.local_file.aws_worker_tasks]

# }