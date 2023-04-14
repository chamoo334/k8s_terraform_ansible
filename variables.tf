# Decalre cloud provider
variable "cloud_provider" {
    description = "Declare cloud provider to use"
    type = map(bool)
}

# AWS Configuration
variable "aws_cli" {
    description = "Environment variables to configure the AWS CLI and AWS region"
    type = map
    sensitive   = true
}

variable "ami_id" {
    description = "ID of AMI to use. Default is AL2"
    type = string
    default = "ami-06e46074ae430fba6" 
}

variable "instance_type" {
    description = "Instance type to use for all instances."
    type = string
}

variable "key_pair_name" {
    description = "Preferred name for generated key pair."
    type = string
}

variable "sg_k8s_controller_ingress" {
    description = "Security group rules for cluster controller"
    type = map(object({
        port = number
        protocol = string
        cidr_blocks = list(string)
        description = string
    }))
    default = {
        "22" = {
            port = 22
            description = "SSH access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "80" = {
            port = 80
            description = "HTTP access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "443" = {
            port = 443
            description = "HTTPS access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

variable "sg_k8s_worker_ingress" {
    description = "Security group rules for cluster worker nodes"
    type = map(object({
        port = number
        protocol = string
        cidr_blocks = list(string)
        description = string
    }))
    default = {
        "22" = {
            port = 22
            description = "SSH access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "80" = {
            port = 80
            description = "HTTP access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "443" = {
            port = 443
            description = "HTTPS access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "" = {
            description = ""
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}