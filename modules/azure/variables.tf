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
  type        = string
}

variable "network_address_space" {
  description = "Virtual network address space"
  type        = list(string)
}

variable "vm_names" {
  description = "Hostname and tags of virtual machines."
  type        = map(string)
}

variable "sg_k8s_controller" {
  description = "Security group rules for cluster controller"
  type = map(object({
    name                   = string
    description            = string
    priority               = number
    protocol               = string
    source_port_range      = string
    destination_port_range = string
  }))
}

variable "sg_k8s_worker" {
  description = "Security group rules for cluster controller"
  type = map(object({
    name                   = string
    description            = string
    priority               = number
    protocol               = string
    source_port_range      = string
    destination_port_range = string
  }))
}

variable "vm_size" {
  description = "Virtual machine size"
  type        = string
}
variable "admin_username" {
  description = "USername for admin on virtual machines"
  type        = string
}
variable "disable_password_authentication" {
  description = "Disable password authentication on virtual machines"
  type        = bool
}

variable "source_image" {
  description = "Virtual machine source image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}