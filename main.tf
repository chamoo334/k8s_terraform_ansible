# create inventory file for Ansible
resource "local_file" "inventory" {
    filename = "./ansible/inventory.yaml"
    content = <<-EOT
all:
  children:
EOT
}

# Create Ansible playbook
resource "local_file" "playbook" {
    filename = "./ansible/playbook.yaml"
    content = <<-EOT
%{ if var.cloud_provider.aws }
- name: Create AWS Kubernetes clusters
  hosts: aws
  gather_facts: no
  remote_user: root
  become: yes
  roles:
    - aws%{ endif }
%{ if var.cloud_provider.azure }
- name: Create Azure Kubernetes clusters
  hosts: azure
  gather_facts: no
  remote_user: root
  become: yes
  roles:
    - azure%{ endif }
%{ if var.cloud_provider.gcp }
- name: Create GCP Kubernetes clusters
  hosts: gcp
  gather_facts: no
  remote_user: root
  become: yes
  roles:
    - gcp%{ endif }
EOT
}

## create kubernetes cluster in AWS
module "aws_k8s" {
    count = var.cloud_provider.aws ? 1 : 0
    source = "./modules/aws"
    ami_id = var.ami_id
    ec2_names = var.vm_names
    instance_type = var.instance_type
    key_pair_name = var.key_pair_name
    sg_name_prefix = var.sg_name_prefix
    sg_k8s_controller_ingress = var.sg_k8s_controller_ingress
    sg_k8s_worker_ingress = var.sg_k8s_controller_ingress

    depends_on = [local_file.inventory]
}

## create kubernetes cluster in Azure
# module "azure_k8s" {
#     count = var.cloud_provider.azure ? 1 : 0
#     source = "./modules/azure"

#     depends_on = [local_file.inventory]
# }

# create kubernetes cluster in GCP
# module "gcp_k8s" {
#     count = var.cloud_provider.gcp ? 1 : 0
#     source = "./modules/gcp"

#     depends_on = [local_file.inventory]
# }

# Set Ansible roles path and run created playbook with created inventory
resource "null_resource" "run_playbook" {
#     provisioner "local-exec" {
#         command = <<-EOT
# export ANSIBLE_ROLES_PATH=./ansible/roles
# ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml -T 720 > ./ansible/plays.log
# EOT
#     }

    provisioner "local-exec" {
        when = destroy
        command = <<-EOT
unset ANSIBLE_ROLES_PATH
if test -f ./ansible/inventory.yaml; then rm ./ansible/inventory.yaml; fi
if test -f ./ansible/plays.log; then rm ./ansible/plays.log; fi
EOT
    }

    depends_on = [local_file.inventory, local_file.playbook, module.aws_k8s]
    # depends_on = [local_file.inventory, local_file.playbook, module.aws_k8s.null_resource.aws_inventory, module.aws_k8s.local_file.aws_worker_tasks]

}