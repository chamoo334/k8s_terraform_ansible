output "ssh_commands" {
  value = {
    for node in local.instances : var.ec2_names[node] => "ssh -i ./ansible/aws_${var.key_pair_name}.pem ec2-user@${aws_instance.k8s["${node}"].public_dns}"
  }
}

output "private_key_file" {
  value = local_file.k8s_key.filename
}

output "controller_public_ip" {
  value = aws_instance.k8s["${local.instances[0]}"].public_ip
}

output "workers" {
  value = slice(local.instances, 1, length(local.instances))
}

output "worker_public_ips" {
  value = {
    for node in local.instances : node => aws_instance.k8s["${node}"].public_ip if node != local.instances[0]
  }
}

