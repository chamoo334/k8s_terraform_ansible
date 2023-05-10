output "aws_ssh_commands" {
  value = try(module.aws_k8s[0].ssh_commands, "0 AWS VMs")
}

output "azure_ssh_commands" {
  value = try(module.azure_k8s[0].ssh_commands, "0 Azure VMs")
}

output "gcp_ssh_commands" {
  value = try(module.gcp_k8s[0].ssh_commands, "0 GCP VMs")
}