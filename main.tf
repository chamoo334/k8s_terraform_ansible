resource "local_file" "inventory" {
    filename = "./ansible/inventory.yaml"
    content = <<-EOT
all:
  children:
EOT
}

resource "local_file" "ansible_script" {
    filename = "./ansible.sh"
    content = <<-EOT
#!/bin/bash
EOT
}

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

    depends_on = [local_file.inventory, local_file.ansible_script]
}

module "azure_k8s" {
    count = var.cloud_provider.azure ? 1 : 0
    source = "./modules/azure"

    depends_on = [local_file.inventory, local_file.ansible_script]
}

module "gcp_k8s" {
    count = var.cloud_provider.gcp ? 1 : 0
    source = "./modules/gcp"

    depends_on = [local_file.inventory, local_file.ansible_script]
}

# resource "null_resource" "run_playbooks" {
#     provisioner "local-exec" {
#         command = "bash ./ansible.sh 2>> errors.log"
#     }

#     depends_on = [local_file.inventory, local_file.ansible_script, module.aws_k8s, module.azure_k8s, module.gcp_k8s]
# }