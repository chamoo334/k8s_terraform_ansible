output "ssh_commands" {
  value = {
    for node in local.machines : var.vm_names[node] => "ssh -i ${local_file.k8s_key.filename} ${var.admin_username}@${azurerm_linux_virtual_machine.k8s["${node}"].public_ip_address}"
  }
}

output "private_key_file" {
  value = local_file.k8s_key.filename
}

output "controller_public_ip" {
  value = azurerm_linux_virtual_machine.k8s["${local.machines[0]}"].public_ip_address
}

output "workers" {
  value = slice(local.machines, 1, length(local.machines))
}

output "worker_public_ips" {
  value = {
    for node in local.machines : node => azurerm_linux_virtual_machine.k8s["${node}"].public_ip_address if node != local.machines[0]
  }
}
