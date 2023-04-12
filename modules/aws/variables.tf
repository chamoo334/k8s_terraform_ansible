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