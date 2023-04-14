variable "ec2_names" {
    description = "Hostname and tags of EC2 instances."
    type = map(string)
    default = {
        "controller" = "k8s-controller"
        "worker1" = "k8s-worker-1"
        "worker2" = "k8s-worker-2"
    }
}

variable "ami_id" {
    description = "ID of AMI to use"
    type = string
}

variable "instance_type" {
    description = "Instance type to use for all instances."
    type = string
}

variable "key_pair_name" {
    description = "Preferred name for generated key pair."
    type = string
}

variable "sg_name" {
    description = "Preferred name of generated security group."
    type = string
    default = "k8s"
}

variable "sg_k8s_controller_ingress" {
    description = "Security group rules for cluster controller"
    type = map(object({
        port = number
        protocol = string
        cidr_blocks = list(string)
        description = string
    }))
}

variable "sg_k8s_worker_ingress" {
    description = "Security group rules for cluster controller"
    type = map(object({
        port = number
        protocol = string
        cidr_blocks = list(string)
        description = string
    }))
}