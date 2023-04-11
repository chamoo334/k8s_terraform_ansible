# Decalre cloud provider
variable "cloud_provider" {
    description = "Declare cloud provider to use"
    type = map(bool)
}

# AWS CLI Information
variable "aws_cli" {
    description = "AWS region, access key id, and secret access key"
    type = map
}