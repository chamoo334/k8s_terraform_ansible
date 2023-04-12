# Configure the AWS Provider
provider "aws" {
    region = var.aws_cli.region
    access_key = var.aws_cli.access_key
    secret_key = var.aws_cli.secret_key
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    # Configuration options
}

# Configure the GCP Provider
provider "google" {
    # Configuration options
}