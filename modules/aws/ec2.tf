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
    filename = "./ansible/aws/hosts.txt"
    content = <<-EOT
      shell: |
        cat <<EOF | sudo tee /etc/hosts
%{ for node in local.instances ~}
        ${aws_instance.k8s["${node}"].private_ip} ${var.ec2_names["${node}"]}
%{ endfor ~}
        EOF
EOT

    provisioner "local-exec" {
        command = "sed -i '' '/name: Configure hosts/r ./ansible/aws/hosts.txt' ./ansible/aws/all.yaml"
    }
    
    provisioner "local-exec" {
        when = destroy
        command = <<-EOT
export line1=$(($(grep -n "name: Configure hosts" ./ansible/aws/all.yaml | cut -d: -f1)+1))
export line2=$(($(grep -n "name: Install iproute" ./ansible/aws/all.yaml | cut -d: -f1)-1))
sed -i '' -e "$line1","$line2"d ./ansible/aws/all.yaml
unset line1
unset line2
EOT
    }
}