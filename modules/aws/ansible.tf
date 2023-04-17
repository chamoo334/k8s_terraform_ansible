resource "local_file" "aws_inventory" {
    filename = "./scripts/ansible/aws.yaml"
    content = <<-EOT
sudo cat <<EOF | sudo tee /etc/hosts
%{ for node in local.instances ~}
${aws_instance.k8s["${node}"].private_ip} ${var.ec2_names["${node}"]}
%{ endfor ~}
EOF
EOT
    depends_on = [aws_instance.k8s]
}

# resource "ansible_host" "k8s-c" {
#     name = aws_instance.k8s["controller"].public_ip
#     groups = ["all"]
#     variables = {
#         ansible_user = "ec2-user"
#         ansible_ssh_private_key_file = local_file.k8s_key.filename
#         # ansible_pyhton_interpreter = "/usr/bin/python3"
#     }
#     depends_on = [aws_instance.k8s]
# }