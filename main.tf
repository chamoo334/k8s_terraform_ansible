#! Create Kubernetes cluster in AWS
module "aws_k8s" {
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
  source         = "./modules/gcp"
  vm_names       = var.vm_names
  ssh_key_name   = var.project_id
  network        = var.gcp.network
  machine_type   = var.gcp.machine_type
  image          = var.gcp.image
  admin_username = var.gcp.admin_username
  firewalls      = local.gcp_firewall
}

#! Add AWS hosts to Ansible inventory
resource "null_resource" "aws_inventory" {
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ./ansible/inventory.yaml
    aws:
      vars:
        ansible_port: 22
        ansible_user: ec2-user
        ansible_ssh_private_key_file: ${module.aws_k8s.private_key_file}
      hosts:
        aws_controller:
          ansible_host: ${module.aws_k8s.controller_public_ip}
      children:
        aws_workers:
          hosts:%{for node in module.aws_k8s.workers}
            aws_${node}:
              ansible_host: ${module.aws_k8s.worker_public_ips[node]}%{endfor}
EOF
sed -i '' '/name: Configure hosts on AWS/r ./ansible/aws_hosts.txt' ./ansible/roles/k8s/tasks/main.yaml
EOT
  }

  depends_on = [module.aws_k8s]
}

#! Add Azure hosts to Ansible inventory
resource "null_resource" "azure_inventory" {
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ./ansible/inventory.yaml
    azure:
      vars:
        ansible_port: 22
        ansible_user: ${var.azure.admin_username}
        ansible_ssh_private_key_file: ${module.azure_k8s.private_key_file}
      hosts:
        azure_controller:
          ansible_host: ${module.azure_k8s.controller_public_ip}
      children:
        azure_workers:
          hosts:%{for node in module.azure_k8s.workers}
            azure_${node}:
              ansible_host: ${module.azure_k8s.worker_public_ips[node]}%{endfor}
EOF
sed -i '' '/name: Configure hosts on Azure/r ./ansible/azure_hosts.txt' ./ansible/roles/k8s/tasks/main.yaml
EOT
  }

  depends_on = [module.azure_k8s]
}

#! Add GCP hosts to Ansible inventory
resource "null_resource" "gcp_inventory" {
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ./ansible/inventory.yaml
    gcp:
      vars:
        ansible_port: 22
        ansible_user: ${var.gcp.admin_username}
        ansible_ssh_private_key_file: ${module.gcp_k8s.private_key_file}
      hosts:
        gcp_controller:
          ansible_host: ${module.gcp_k8s.controller_public_ip}
      children:
        gcp_workers:
          hosts:%{for node in module.gcp_k8s.workers}
            gcp_${node}:
              ansible_host: ${module.gcp_k8s.worker_public_ips[node]}%{endfor}
EOF
sed -i '' '/name: Configure hosts on GCP/r ./ansible/gcp_hosts.txt' ./ansible/roles/k8s/tasks/main.yaml
EOT
  }

  depends_on = [module.gcp_k8s]
}