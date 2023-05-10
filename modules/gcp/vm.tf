resource "google_compute_address" "k8s" {
  for_each  = var.vm_names
  name      = each.value
}

resource "google_compute_instance" "k8s" {
  for_each     = var.vm_names
  name         = each.value
  machine_type = var.machine_type
  tags         = each.key == local.machines[0] ? ["controller"] : ["worker"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = var.network

    access_config {
        nat_ip = google_compute_address.k8s["${each.key}"].address
    }
  }

  metadata = {
    ssh-keys = "${var.admin_username}:${tls_private_key.k8s.public_key_openssh}"
  }

  allow_stopping_for_update = true

  provisioner "remote-exec" {
    inline = ["echo 'connected!'"]

    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = file("${local_file.k8s_key.filename}")
      host        = google_compute_address.k8s["${each.key}"].address
    }
  }
}

# store private ips in local file, and update ansible role
resource "local_file" "k8s_private_ips" {
  filename = "./ansible/gcp_hosts.txt"
  content  = <<-EOT
  shell: |
    cat <<EOF | sudo tee /etc/hosts
%{for node in local.machines~}
    ${google_compute_instance.k8s["${node}"].network_interface.0.network_ip} ${var.vm_names["${node}"]}
%{endfor~}
    EOF
EOT

  provisioner "local-exec" {
    command = "sed -i '' '/name: Configure hosts/r ./ansible/gcp_hosts.txt' ./ansible/roles/gcp/tasks/main.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
export line1=$(($(grep -n "name: Configure hosts" ./ansible/roles/gcp/tasks/main.yaml | cut -d: -f1)+1));
export line2=$(($(grep -n "name: Install iproute" ./ansible/roles/gcp/tasks/main.yaml | cut -d: -f1)-2));
sed -i '' -e "$line1","$line2"d ./ansible/roles/gcp/tasks/main.yaml;
unset line1;
unset line2;
EOT
  }

}