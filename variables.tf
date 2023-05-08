# General project information
variable "cloud_provider" {
  description = "Declare cloud provider/s to use"
  type = object({
    aws = bool
    azure = bool
    gcp = bool 
  })
}

variable "project_id" {
  description = "Identifier for resources created in all cloud platforms."
  type        = string
}

variable "vm_names" {
  description = "Hostname and tags of instances."
  type        = map(string)
  default = {
    "controller" = "k8s-controller"
    "worker1"    = "k8s-worker-1"
    "worker2"    = "k8s-worker-2"
  }
}

# AWS Configuration
variable "aws" {
  description = "Variables to configure AWS"
  type = object({
    creds = object({
      region     = string
      access_key = string
      secret_key = string
    })
    ami_id        = string
    instance_type = string
    controller_ingress = map(object({
      start_port  = number
      end_port    = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
    worker_ingress = map(object({
      start_port  = number
      end_port    = number
      protocol    = string
      cidr_blocks = list(string)
      description = string
    }))
  })

  default = {
    creds = {
      region     = ""
      access_key = ""
      secret_key = ""
    }
    ami_id        = ""
    instance_type = ""
    controller_ingress = {
      "22" = {
        start_port  = 22
        end_port    = 22
        description = "SSH access"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "80" = {
        start_port  = 80
        end_port    = 80
        description = "HTTP access"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "443" = {
        start_port  = 443
        end_port    = 443
        description = "HTTPS access"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "6443" = {
        start_port  = 6443
        end_port    = 6443
        description = "Kubernetes API server"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "2379" = {
        start_port  = 2379
        end_port    = 2380
        description = "etcd server client API"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "10250" = {
        start_port  = 10250
        end_port    = 10250
        description = "Kubelet API"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "10259" = {
        start_port  = 10259
        end_port    = 10259
        description = "kube-scheduler"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "10257" = {
        start_port  = 10257
        end_port    = 10257
        description = "kube-controller-manager"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    worker_ingress = {
      "22" = {
        start_port  = 22
        end_port    = 22
        description = "SSH access"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "80" = {
        start_port  = 80
        end_port    = 80
        description = "HTTP access"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "443" = {
        start_port  = 443
        end_port    = 443
        description = "HTTPS access"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "10250" = {
        start_port  = 10250
        end_port    = 10250
        description = "Kubelet API"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      "30000" = {
        start_port  = 30000
        end_port    = 32767
        description = "NodePort Services"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  }
}

# Azure Configuration
variable "azure" {
  description = "Variables to configure the Azure"
  type = object({
    creds = object({
      subscription_id = string
      tenant_id       = string
      client_id       = string
      client_secret   = string
    })
    resource_group_location         = string
    address_space                   = list(string)
    vm_size                         = string
    admin_username                  = string
    disable_password_authentication = bool
    source_image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    controller_sg = map(object({
      name                   = string
      description            = string
      priority               = number
      protocol               = string
      source_port_range      = string
      destination_port_range = string
    }))
    worker_sg = map(object({
      name                   = string
      description            = string
      priority               = number
      protocol               = string
      source_port_range      = string
      destination_port_range = string
    }))
  })

  default = {
    creds = {
      subscription_id = ""
      tenant_id       = ""
      client_id       = ""
      client_secret   = ""
    }
    resource_group_location         = ""
    address_space                   = [""]
    vm_size                         = ""
    admin_username                  = ""
    disable_password_authentication = false
    source_image = {
      publisher = ""
      offer     = ""
      sku       = ""
      version   = ""
    }
    controller_sg = {
      "22" = {
        name                   = "ssh-k8s-controller"
        description            = "SSH access"
        priority               = 100
        protocol               = "Tcp"
        source_port_range      = "22"
        destination_port_range = "22"
      }
      "80" = {
        name                   = "http-k8s-controller"
        description            = "HTTP access"
        priority               = 200
        protocol               = "Tcp"
        source_port_range      = "80"
        destination_port_range = "80"
      }
      "443" = {
        name                   = "https-k8s-controller"
        description            = "HTTPS access"
        priority               = 300
        protocol               = "Tcp"
        source_port_range      = "443"
        destination_port_range = "443"
      }
      "6443" = {
        name                   = "k8s-api-controller"
        description            = "Kubernetes API server"
        priority               = 400
        protocol               = "Tcp"
        source_port_range      = "6443"
        destination_port_range = "6443"
      }
      "2379" = {
        name                   = "k8s-etcd-controller"
        description            = "etcd server client API"
        priority               = 500
        protocol               = "Tcp"
        source_port_range      = "2379-2380"
        destination_port_range = "2379-2380"
      }
      "10250" = {
        name                   = "kubelet-controller"
        description            = "Kubelet API"
        priority               = 600
        protocol               = "Tcp"
        source_port_range      = "10250"
        destination_port_range = "10250"
      }
      "10259" = {
        name                   = "scheduler-controller"
        description            = "kube-scheduler"
        priority               = 700
        protocol               = "Tcp"
        source_port_range      = "10259"
        destination_port_range = "10259"
      }
      "10257" = {
        name                   = "kube-controller-manager"
        description            = "kube-controller-manager"
        priority               = 800
        protocol               = "Tcp"
        source_port_range      = "10257"
        destination_port_range = "10257"
      }
    }
    worker_sg = {
      "22" = {
        name                   = "ssh-k8s-worker"
        description            = "SSH access"
        priority               = 100
        protocol               = "Tcp"
        source_port_range      = "22"
        destination_port_range = "22"
      }
      "80" = {
        name                   = "http-k8s-worker"
        description            = "HTTP access"
        priority               = 200
        protocol               = "Tcp"
        source_port_range      = "80"
        destination_port_range = "80"
      }
      "443" = {
        name                   = "https-k8s-worker"
        description            = "HTTPS access"
        priority               = 300
        protocol               = "Tcp"
        source_port_range      = "443"
        destination_port_range = "443"
      }
      "10250" = {
        name                   = "kubelet-worker"
        description            = "Kubelet API"
        priority               = 400
        protocol               = "Tcp"
        source_port_range      = "10250"
        destination_port_range = "10250"
      }
      "30000" = {
        name                   = "nodeport-services"
        description            = "NodePort Services"
        priority               = 500
        protocol               = "Tcp"
        source_port_range      = "30000-32767"
        destination_port_range = "30000-32767"
      }
    }
  }
}

# GCP Configuration
variable "gcp" {
  description = "Variables to configure the GCP"
  type = object({
    creds = object({
      project     = string
      region      = string
      zone        = string
      credentials = string
    })
    network      = string
    machine_type = string
    image        = string
    admin_username = string
    firewalls = map(object({
      network       = string
      target_tags   = list(string)
      source_ranges = list(string)
      protocol      = string
      ports         = list(string)
    }))
  })

  default = {
    creds = {
      project     = ""
      region      = ""
      zone        = ""
      credentials = ""
    }
    network      = ""
    machine_type = ""
    image        = ""
    admin_username = ""
    firewalls = {
      k8s-controller = {
        network       = ""
        target_tags   = [""]
        source_ranges = [""]
        protocol      = ""
        ports         = [""]
      }
      k8s-worker = {
        network       = ""
        target_tags   = [""]
        source_ranges = [""]
        protocol      = ""
        ports         = [""]
      }
    }
  }
}