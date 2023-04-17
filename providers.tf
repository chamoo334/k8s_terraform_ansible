# Configure the AWS provider
provider "aws" {
    region = var.aws_cli.region
    access_key = var.aws_cli.access_key
    secret_key = var.aws_cli.secret_key
}

# Configure the Microsoft Azure provider
provider "azurerm" {
    # Configuration options
}

# Configure the GCP provider
provider "google" {
    # Configuration options
}

# Configure Ansible provider
provider "ansible" {
  # Configuration options
}