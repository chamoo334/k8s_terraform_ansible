# output "ssh_commands" {
#   value = {
#     for node in local.machines : var.ec2_names[node] => "ssh -i ./ansible/aws_${var.key_pair_name}.pem ec2-user@${aws_instance.k8s["${node}"].public_dns}"
#   }
# }

# output "azure_private_key_file" {
#   value = local_file.k8s_key.filename
# }

# output "azure_controller_public_ip" {
#   value = azure_instance.k8s["${local.machines[0]}"].public_ip
# }

# output "azure_workers" {
#   value = slice(local.machines, 1, length(local.machines))
# }

# output "azure_worker_public_ips" {
#   value = {
#     for node in local.machines : node => azure_instance.k8s["${node}"].public_ip if node != local.machines[0]
#   }
# }