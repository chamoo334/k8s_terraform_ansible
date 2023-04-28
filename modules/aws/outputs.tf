output "ssh_commands" {
  value = {
    for node in local.instances : var.ec2_names[node] => "ssh -i ./ansible/aws_${var.key_pair_name}.pem ec2-user@${aws_instance.k8s["${node}"].public_dns}"
  }
}

output "aws_private_key_file" {
  value = local_file.k8s_key.filename
}

output "aws_controller_public_ip" {
  value = aws_instance.k8s["${local.instances[0]}"].public_ip
}

output "aws_workers" {
  value = slice(local.instances, 1, length(local.instances))
}

output "aws_worker_public_ips" {
  value = {
    for node in local.instances : node => aws_instance.k8s["${node}"].public_ip if node != local.instances[0]
  }
}

