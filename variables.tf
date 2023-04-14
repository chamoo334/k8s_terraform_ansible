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