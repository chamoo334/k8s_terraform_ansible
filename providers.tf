#! Configure the AWS provider
provider "aws" {
 region     = var.aws.creds.region
 access_key = var.aws.creds.access_key
 secret_key = var.aws.creds.secret_key
}

#! Configure the Microsoft Azure provider
provider "azurerm" {
 subscription_id = var.azure.creds.subscription_id
 tenant_id       = var.azure.creds.tenant_id
 client_id       = var.azure.creds.client_id
 client_secret   = var.azure.creds.client_secret
 features {}
}

#! Configure the GCP provider
provider "google" {
  project     = var.gcp.creds.project
  region      = var.gcp.creds.region
  zone        = var.gcp.creds.zone
  credentials = var.gcp.creds.credentials
}