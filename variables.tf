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
    description = "ID of AMI to use. Default is Ubuntu 20.04"
    type = string
    default = "ami-0aa2b7722dc1b5612" 
}

variable "instance_type" {
    description = "Instance type to use for all instances."
    type = string
}