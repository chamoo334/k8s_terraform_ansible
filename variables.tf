# General project information
variable "cloud_provider" {
  description = "Declare cloud provider/s to use"
  type = map(bool)
}

variable "project_id" {
  description = "Identifier for resources created in all cloud platforms."
  type        = string
}

variable "vm_names" {
  description = "Hostname and tags of EC2 instances."
  type        = map(string)
  default = {
    "controller" = "k8s-controller"
    "worker1"    = "k8s-worker-1"
    "worker2"    = "k8s-worker-2"
  }
}

# AWS Configuration
variable "aws_credentials" {
  description = "Variables to configure the AWS access and AWS region"
  sensitive   = true
  type = map
}

variable "aws_controller_ingress" {
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
}

variable "aws_worker_ingress" {
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

variable "ami_id" {
  description = "ID of AMI to use."
  type        = string
}

variable "instance_type" {
  description = "Instance type to use for all instances."
  type        = string
}

# Azure Configuration
variable "azure_credentials" {
  description = "Variables to configure the Azure access"
  type        = map(any)
  sensitive   = true
}

variable "resource_group_location" {
  description = "Location of resource group"
  type        = string
}

variable "azure_address_space" {
  description = "Virtual network address space along with 2 subnet adress prefixes"
  type = list(string)
}

variable "azure_controller_sg" {
  description = "Security group rules for cluster controller"
  type = map(object({
    name = string
    description = string
    priority   = number
    protocol   = string
    source_port_range   = string
    destination_port_range     = string
  }))
  default = {
    "22" = {
      name = "ssh-k8s-controller"
      description = "SSH access"
      priority = 100
      protocol = "Tcp"
      source_port_range = "22"
      destination_port_range = "22"
    }
    "80" = {
      name = "http-k8s-controller"
      description = "HTTP access"
      priority = 200
      protocol    = "Tcp"
      source_port_range  = "80"
      destination_port_range    = "80"
    }
    "443" = {
      name = "https-k8s-controller"
      description = "HTTPS access"
      priority = 300
      protocol    = "Tcp"
      source_port_range = "443"
      destination_port_range    = "443"
    }
    "6443" = {
      name = "k8s-api-controller"
      description = "Kubernetes API server"
      priority = 400
      protocol    = "Tcp"
      source_port_range = "6443"
      destination_port_range    = "6443"
    }
    "2379" = {
      name = "k8s-etcd-controller"
      description = "etcd server client API"
      priority = 500
      protocol    = "Tcp"
      source_port_range = "2379-2380"
      destination_port_range    = "2379-2380"
    }
    "10250" = {
      name = "kubelet-controller"
      description = "Kubelet API"
      priority = 600
      protocol    = "Tcp"
      source_port_range = "10250"
      destination_port_range    = "10250"
    }
    "10259" = {
      name = "scheduler-controller"
      description = "kube-scheduler"
      priority = 700
      protocol    = "Tcp"
      source_port_range = "10259"
      destination_port_range    = "10259"
    }
    "10257" = {
      name = "kube-controller-manager"
      description = "kube-controller-manager"
      priority = 800
      protocol    = "Tcp"
      source_port_range = "10257"
      destination_port_range    = "10257"
    }
  }
}

variable "azure_worker_sg" {
  description = "Security group rules for cluster worker nodes"
  type = map(object({
    name = string
    description = string
    priority   = number
    protocol   = string
    source_port_range   = string
    destination_port_range     = string
  }))
  default = {
    "22" = {
      name = "ssh-k8s-worker"
      description = "SSH access"
      priority = 100
      protocol = "Tcp"
      source_port_range = "22"
      destination_port_range = "22"
    }
    "80" = {
      name = "http-k8s-worker"
      description = "HTTP access"
      priority = 200
      protocol    = "Tcp"
      source_port_range  = "80"
      destination_port_range    = "80"
    }
    "443" = {
      name = "https-k8s-worker"
      description = "HTTPS access"
      priority = 300
      protocol    = "Tcp"
      source_port_range = "443"
      destination_port_range    = "443"
    }
    "10250" = {
      name = "kubelet-worker"
      description = "Kubelet API"
      priority = 400
      protocol    = "Tcp"
      source_port_range = "10250"
      destination_port_range    = "10250"
    }
    "30000" = {
      name = "nodeport-services"
      description = "NodePort Services"
      priority = 500
      protocol    = "Tcp"
      source_port_range  = "30000-32767"
      destination_port_range    = "30000-32767"
    }
  }
}

variable "vm_size " {
  description = "Virtual machine size"
  type = string
}
variable "admin_username" {
  description = "USername for admin on virtual machines"
  type = string
}
variable "disable_password_authentication" {
  description = "Disable password authentication on virtual machines"
  type = bool
}

variable "source_image" {
  description = "Virtual machine source image reference"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
}

# GCPConfiguration
# variable "gcp_credentials" {
#     description = "Variables to configure the GCP access"
#     type = map
#     sensitive   = true
# }