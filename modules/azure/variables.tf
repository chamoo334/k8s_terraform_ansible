variable "resource_group_name" {
  description = "Name of resource group"
  type        = string
}

variable "resource_group_location" {
  description = "Location of resource group"
  type        = string
}

variable "ssh_key_name" {
  description = "Preferred name for generated key pair."
  type        = string
}

variable "network_name" {
  description = "Name of network wherein virtual machines where reside"
  type = string
}

variable "network_address_space" {
  description = "Virtual network address space"
  type = list(string)
}

variable "vm_names" {
  description = "Hostname and tags of virtual machines."
  type        = map(string)
}