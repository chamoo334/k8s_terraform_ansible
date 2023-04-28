# Configure the AWS provider
provider "aws" {
  region     = var.aws_credentials.region
  access_key = var.aws_credentials.access_key
  secret_key = var.aws_credentials.secret_key
}

# Configure the Microsoft Azure provider
provider "azurerm" {
  subscription_id = var.azure_credentials.subscription_id
  tenant_id       = var.azure_credentials.tenant_id
  client_id       = var.azure_credentials.client_id
  client_secret   = var.azure_credentials.client_secret
  features {}
}

# Configure the GCP provider
provider "google" {
  # Configuration options
}

# Configure Ansible provider
provider "ansible" {
  # Configuration options
}