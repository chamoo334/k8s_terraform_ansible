resource "aws_instance" "k8s" {
    for_each = var.ec2_names
    
    ami           = var.ami_id
    instance_type = var.instance_type
    associate_public_ip_address = true
    key_name = aws_key_pair.k8s.key_name
    security_groups = each.key == "controller" ? [aws_security_group.k8s-controller.name] : [aws_security_group.k8s-worker.name]
    
    tags = {
        Name = each.value
    }
}

resource "local_file" "k8s_private_ips" {
    filename = "./scripts/aws/hosts.txt"
    content = <<-EOT
sudo cat <<EOF | sudo tee /etc/hosts
%{ for node in local.instances ~}
${aws_instance.k8s["${node}"].private_ip} ${var.ec2_names["${node}"]}
%{ endfor ~}
EOF
EOT
}

resource "null_resource" "k8s_script_unix2" {
    provisioner "local-exec" {
        command = "sed -i '' '/# configure network/r ./scripts/aws/hosts.txt' ./scripts/aws/all_nodes.sh"
    }
    depends_on = [local_file.k8s_private_ips]
}
