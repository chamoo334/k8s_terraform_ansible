variable "vm_names" {
  description = "Hostname and tags of virtual machines."
  type        = map(string)
}

variable "ssh_key_name" {
  description = "Preferred name for generated key pair."
  type        = string
}

variable "network" {
  description = "Network to provision resources"
  type        = string
}

variable "machine_type" {
  description = "Instance machine type"
  type        = string
}

variable "image" {
  description = "Instance image"
  type        = string
}

variable "admin_username" {
  description = "Username for admin on virtual machines"
  type        = string
}

variable "firewalls" {
  description = "Network Firewall rules for cluster instances"
  type = map(object({
    target_tags   = list(string)
    source_ranges = list(string)
    protocol      = string
    ports         = list(string)
  }))
}