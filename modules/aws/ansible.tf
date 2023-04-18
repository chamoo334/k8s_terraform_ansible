resource "local_file" "aws_inventory" {
    filename = "./ansible/aws_inventory.yaml"
    content = <<-EOT
all:
  vars:
    ansible_port: 22
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ${local_file.k8s_key.filename}
  children:
    controllers:
      hosts:
        aws_controller:
          ansible_host: ${aws_instance.k8s["controller"].public_ip}
    workers:
      hosts:%{ for node in local.instances }%{ if node != local.instances[0] }
        aws_${node}:
          ansible_host: ${aws_instance.k8s["${node}"].public_ip}%{ endif }%{ endfor }
EOT
    depends_on = [aws_instance.k8s]
}

# -i ./ansible/aws_inventory.yaml all.yaml
# -i ./ansible/aws_inventory.yaml controller.yaml
# -i ./ansible/aws_inventory.yaml workers.yaml