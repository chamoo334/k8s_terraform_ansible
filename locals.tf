locals {
    controller_priority = {
        for key in keys(var.sg_controller):
          key => 100 + index(keys(var.sg_controller), key)
    }

    worker_priority = {
        for key in keys(var.sg_worker):
          key => 100 + index(keys(var.sg_worker), key)
    }

    azure_sg = {
        controller = {
            for key, value in var.sg_controller: key => {
                name = value.description
                description = value.description
                priority = local.controller_priority["${key}"]
                protocol = value.protocol == "tcp" ? "Tcp" : "Udp"
                source_port_range = "*" # "${value.start_port}-${value.end_port}"
                destination_port_range = value.start_port == value.end_port ? "${value.start_port}" : "${value.start_port}-${value.end_port}"
            }
        }
        worker = {
            for key, value in var.sg_worker: key => {
                name = value.description
                description = value.description
                priority = local.worker_priority["${key}"]
                protocol = value.protocol == "tcp" ? "Tcp" : "Udp"
                source_port_range = "*" # "${value.start_port}-${value.end_port}"
                destination_port_range = value.start_port == value.end_port ? "${value.start_port}" : "${value.start_port}-${value.end_port}"
            }
        }
    }

    gcp_firewall = {
        k8s-controller = {
            target_tags   = ["controller"]
            source_ranges = ["0.0.0.0/0"]
            protocol      = "tcp"
            ports = [for key, value in var.sg_controller : value.start_port == value.end_port ? "${value.start_port}" : "${value.start_port}-${value.end_port}"]
        }
        k8s-worker = {
            target_tags   = ["worker"]
            source_ranges = ["0.0.0.0/0"]
            protocol      = "tcp"
            ports = [for key, value in var.sg_worker : value.start_port == value.end_port ? "${value.start_port}" : "${value.start_port}-${value.end_port}"]
        }
    }
}