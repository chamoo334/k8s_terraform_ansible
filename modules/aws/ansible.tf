resource "null_resource" "aws_inventory" {
    provisioner "local-exec" {
        command = <<-EOT
cat <<EOF >> ./ansible/inventory.yaml
    aws:
      vars:
        ansible_port: 22
        ansible_user: ec2-user
        ansible_ssh_private_key_file: ${local_file.k8s_key.filename}
      children:
        aws_controllers:
          hosts:
            aws_controller:
              ansible_host: ${aws_instance.k8s["controller"].public_ip}
        aws_workers:
          hosts:%{ for node in local.instances }%{ if node != local.instances[0] }
            aws_${node}:
              ansible_host: ${aws_instance.k8s["${node}"].public_ip}%{ endif }%{ endfor }
EOF
EOT
    }
    depends_on = [aws_instance.k8s]
}

# -i ./ansible/inventory.yaml ./ansible/aws/all.yaml
# -i ./ansible/inventory.yaml ./ansible/aws/controllers.yaml
# -i ./ansible/inventory.yaml ./ansible/aws/workers.yaml