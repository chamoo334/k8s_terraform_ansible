# Configure the AWS Provider
provider "aws" {
    region = var.aws.region
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    # Configuration options
}

# Configure the GCP Provider
provider "google" {
    # Configuration options
}