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

  depends_on = []
}

# Update Ansible k8s role tasks to configure hosts for each provider
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
    when    = destroy
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

  depends_on = [null_resource.add_inventory_groups]
}

# Remove hosts from inventory
resource "null_resource" "clean_inventory" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
 echo "all:\n  children:" > ./ansible/inventory.yaml
 EOT
  }

  depends_on = [null_resource.add_inventory_groups, null_resource.update_tasks]
}

resource "null_resource" "run_ansible" {
  
  provisioner "local-exec" {
    command = "ansible-playbook -i=./ansible/inventory.yaml ./ansible/playbook.yaml -T=720"
  }

  depends_on = [null_resource.add_inventory_groups, null_resource.update_tasks]
}