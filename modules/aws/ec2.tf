resource "aws_instance" "k8s" {
  for_each = var.ec2_names

  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = aws_key_pair.k8s.key_name
  security_groups             = each.key == "controller" ? [aws_security_group.k8s-controller.name] : [aws_security_group.k8s-worker.name]

  tags = {
    Name = each.value
  }

  provisioner "remote-exec" {
    inline = ["echo 'connected!'"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${local_file.k8s_key.filename}")
      host        = self.public_ip
    }
  }
}

# store private ips in local file, and update ansible role
resource "local_file" "k8s_private_ips" {
  filename = "./ansible/aws_hosts.txt"
  content  = <<-EOT
  when: "'aws' in group_names"
  shell: |
    cat <<EOF | sudo tee /etc/hosts
%{for node in local.instances~}
    ${aws_instance.k8s["${node}"].private_ip} ${var.ec2_names["${node}"]}
%{endfor~}
    EOF
EOT
}