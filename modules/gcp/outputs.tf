output "ssh_commands" {
  value = {
    for node in local.machines : var.vm_names[node] => "ssh -i ${local_file.k8s_key.filename} ${var.admin_username}@${google_compute_instance.k8s["${node}"].network_interface.0.access_config.0.nat_ip}"
  }
}

output "private_key_file" {
  value = local_file.k8s_key.filename
}

output "controller_public_ip" {
  value = google_compute_address.k8s["${local.machines[0]}"].address
}

output "workers" {
  value = slice(local.machines, 1, length(local.machines))
}

output "worker_public_ips" {
  value = {
    for node in local.machines : node => google_compute_address.k8s["${node}"].address if node != local.machines[0]
  }
}
