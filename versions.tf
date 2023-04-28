terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.51.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "4.61.0"
    }

    ansible = {
      source  = "ansible/ansible"
      version = "1.0.0"
    }
  }
}