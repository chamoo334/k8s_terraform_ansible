# General project information
variable "cloud_provider" {
  description = "Declare cloud provider/s to use"
  type = object({
    aws   = bool
    azure = bool
    gcp   = bool
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

variable "sg_controller" {
  description = "Security group rules for cluster controller"
  type = map(object({
    start_port  = number
    end_port    = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = {
    "22" = {
      start_port  = 22
      end_port    = 22
      description = "ssh-access-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "80" = {
      start_port  = 80
      end_port    = 80
      description = "http-access-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "443" = {
      start_port  = 443
      end_port    = 443
      description = "https-access-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "6443" = {
      start_port  = 6443
      end_port    = 6443
      description = "kubernetes-api-server-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "2379" = {
      start_port  = 2379
      end_port    = 2380
      description = "etcd-server-client-api-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "10250" = {
      start_port  = 10250
      end_port    = 10250
      description = "kubelet-api-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "10259" = {
      start_port  = 10259
      end_port    = 10259
      description = "kube-scheduler-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "10257" = {
      start_port  = 10257
      end_port    = 10257
      description = "kube-controller-manager-controller"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

variable "sg_worker" {
  description = "Security group rules for cluster worker nodes"
  type = map(object({
    start_port  = number
    end_port    = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = {
    "22" = {
      start_port  = 22
      end_port    = 22
      description = "ssh-access-worker"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "80" = {
      start_port  = 80
      end_port    = 80
      description = "http-access-worker"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "443" = {
      start_port  = 443
      end_port    = 443
      description = "https-access-worker"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "10250" = {
      start_port  = 10250
      end_port    = 10250
      description = "kubelet-api-worker"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "30000" = {
      start_port  = 30000
      end_port    = 32767
      description = "nodeport-services-worker"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
  })

  default = {
    creds = {
      region     = ""
      access_key = ""
      secret_key = ""
    }
    ami_id        = ""
    instance_type = ""
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
    network        = string
    machine_type   = string
    image          = string
    admin_username = string
  })

  default = {
    creds = {
      project     = ""
      region      = ""
      zone        = ""
      credentials = ""
    }
    network        = ""
    machine_type   = ""
    image          = ""
    admin_username = ""
  }
}