output "ssh_commands" {
  value = {
    for node in local.machines : var.vm_names[node] => "ssh -i ${local_file.k8s_key.filename} @${google_compute_instance.k8s["${node}"].instance_id}"
  }
}
