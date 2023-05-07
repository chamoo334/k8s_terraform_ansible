resource "azurerm_linux_virtual_machine" "k8s" {
    for_each = var.vm_names
    name = each.value
    resource_group_name = azurerm_resource_group.k8s.name
    location            = var.resource_group_location
    size                = var.vm_size
    admin_username      = var.admin_username
    disable_password_authentication = var.disable_password_authentication
    network_interface_ids = [azurerm_network_interface.k8s["${each.key}"].id,]

    admin_ssh_key {
        username   = var.admin_username
        public_key = tls_private_key.k8s.public_key_openssh
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = var.source_image.publisher
        offer     = var.source_image.offer
        sku       = var.source_image.sku
        version   = var.source_image.version
    }

    provisioner "remote-exec" {
        inline = ["echo 'connected!'"]

        connection {
            type        = "ssh"
            user        = var.admin_username
            private_key = file("${local_file.k8s_key.filename}")
            host        = self.public_ip_address
            # host        = azurerm_public_ip.k8s[each.key].id
        }
    }
}

# store private ips in local file, and update ansible role
resource "local_file" "k8s_private_ips" {
  filename = "./ansible/azure_hosts.txt"
  content  = <<-EOT
  shell: |
    cat <<EOF | sudo tee /etc/hosts
%{for node in local.machines~}
    ${azurerm_linux_virtual_machine.k8s["${node}"].private_ip_address} ${var.vm_names["${node}"]}
%{endfor~}
    EOF
EOT

  provisioner "local-exec" {
    command = "sed -i '' '/name: Configure hosts/r ./ansible/azure_hosts.txt' ./ansible/roles/azure/tasks/main.yaml"
  }

}

