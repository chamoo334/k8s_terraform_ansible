data "google_client_openid_userinfo" "me" {}

# resource "google_compute_address" "static_ip" {
#   name = "debian-vm"
# }

resource "google_compute_instance" "k8s" {
    for_each = var.vm_names
    name = each.value
    machine_type = var.machine_type
    tags = each.key == local.machines[0] ? ["controller"] : ["worker"]

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    network_interface {
        network = var.network

        # access_config {
        #     nat_ip = google_compute_address.static_ip.address
        # }
    }
    
    metadata = {
        ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.k8s.public_key_openssh}"
    }
    
    allow_stopping_for_update = true
}