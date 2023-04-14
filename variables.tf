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

variable "key_pair_name" {
    description = "Preferred name for generated key pair."
    type = string
}

variable "sg_name_prefix" {
    description = "Preferred name of generated security group."
    type = string
}

variable "sg_k8s_controller_ingress" {
    description = "Security group rules for cluster controller"
    type = map(object({
        start_port = number
        end_port = number
        protocol = string
        cidr_blocks = list(string)
        description = string
    }))
    default = {
        "22" = {
            start_port = 22
            end_port = 22
            description = "SSH access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "80" = {
            start_port = 80
            end_port = 80
            description = "HTTP access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "443" = {
            start_port = 443
            end_port = 443
            description = "HTTPS access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "6443" = {
            start_port = 6443
            end_port = 6443
            description = "Kubernetes API server"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "2379" = {
            start_port = 2379
            end_port = 2380
            description = "etcd server client API"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "10250" = {
            start_port = 10250
            end_port = 10250
            description = "Kubelet API"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "10259" = {
            start_port = 10259
            end_port = 10259
            description = "kube-scheduler"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "10257" = {
            start_port = 10257
            end_port = 10257
            description = "kube-controller-manager"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        # "6783" = {
        #     start_port = 6783
        #     end_port = 6783
        #     description = "Weavnet CNI"
        #     protocol = "tcp"
        #     cidr_blocks = ["0.0.0.0/0"]
        # }
        # "6784" = {
        #     start_port = 6784
        #     end_port = 6784
        #     description = "Weavnet CNI"
        #     protocol = "udp"
        #     cidr_blocks = ["0.0.0.0/0"]
        # }
    }
}

variable "sg_k8s_worker_ingress" {
    description = "Security group rules for cluster worker nodes"
    type = map(object({
        start_port = number
        end_port = number
        protocol = string
        cidr_blocks = list(string)
        description = string
    }))
    default = {
        "22" = {
            start_port = 22
            end_port = 22
            description = "SSH access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "80" = {
            start_port = 80
            end_port = 80
            description = "HTTP access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "443" = {
            start_port = 443
            end_port = 443
            description = "HTTPS access"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "10250" = {
            start_port = 10250
            end_port = 10250
            description = "Kubelet API"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        "30000" = {
            start_port = 30000
            end_port = 32767
            description = "NodePort Services†"
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        # "6783" = {
        #     start_port = 6783
        #     end_port = 6783
        #     description = "Weavnet CNI"
        #     protocol = "tcp"
        #     cidr_blocks = ["0.0.0.0/0"]
        # }
        # "6784" = {
        #     start_port = 6784
        #     end_port = 6784
        #     description = "Weavnet CNI"
        #     protocol = "udp"
        #     cidr_blocks = ["0.0.0.0/0"]
        # }
    }
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
