
output "ssh_commands" {
    value = {
        for node in local.instances: var.ec2_names[node] => "ssh -i ./ansible/aws_${var.key_pair_name}.pem ec2-user@${aws_instance.k8s["${node}"].public_dns}"
    }
}