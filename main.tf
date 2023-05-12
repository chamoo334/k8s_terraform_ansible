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

#! Add AWS hosts to Ansible inventory
resource "null_resource" "aws_inventory" {
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ./ansible/inventory.yaml
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
sed -i '' '/name: Configure hosts on GCP/r ./ansible/gcp_hosts.txt' ./ansible/roles/k8s/tasks/main.yaml
EOT
  }
  
  depends_on = [module.gcp_k8s, null_resource.azure_inventory]
}

#! Add controllers and workers groups to Ansible inventory
resource "null_resource" "add_inventory_groups" {
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF >> ./ansible/inventory.yaml
    controllers:
      hosts: %{if var.cloud_provider.aws}
        aws_${local.machines[0]}:%{endif}%{if var.cloud_provider.azure}
        azure_${local.machines[0]}:%{endif}%{if var.cloud_provider.azure}
        gcp_${local.machines[0]}:%{endif}
    workers:
      hosts: %{if var.cloud_provider.aws}%{for node in local.machines}%{if node != local.machines[0]}
        aws_${node}:%{endif}%{endfor}%{endif}%{if var.cloud_provider.azure}%{for node in local.machines}%{if node != local.machines[0]}
        azure_${node}:%{endif}%{endfor}%{endif}%{if var.cloud_provider.gcp}%{for node in local.machines}%{if node != local.machines[0]}
        gcp_${node}:%{endif}%{endfor}%{endif}
EOF
EOT
  }

  depends_on = [null_resource.azure_inventory, null_resource.gcp_inventory]
}

resource "null_resource" "update_tasks" {
  for_each = var.cloud_provider
    provisioner "local-exec" {
      command = <<-EOT
 %{if each.value}
 sed -i '' '/name: Configure hosts on ${each.key}/r ./ansible/${each.key}_hosts.txt' ./ansible/roles/k8s/tasks/main.yaml
 %{else}
 sed -i '' 's/^\(- name: Configure hosts on ${each.key}\)$/\1/' ./ansible/roles/k8s/tasks/main.yaml
 %{endif}
 EOT
    }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
 %{if each.value}
 export line1=$(($(grep -n "name: Configure hosts on ${each.key}" ./ansible/roles/k8s/tasks/main.yaml | cut -d: -f1)+1));
 export line2=$(($line1 + $(wc -l ./ansible/${each.key}_hosts.txt | awk '{ print $1 }') - 1))
 sed -i '' -e "$line1","$line2"d ./ansible/roles/k8s/tasks/main.yaml;
 unset line1;
 unset line2;
 %{else}
 sed -i '' "s/- name: Configure hosts on ${each.key}/- name: Configure hosts on ${each.key}/" ./ansible/roles/k8s/tasks/main.yaml
 %{endif}
 EOT
  }
 }

 resource "null_resource" "clean_inventory" {
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
 echo "all:\n  children:" > ./ansible/inventory.yaml
 EOT
  } 
}