locals {
    instances = keys(var.ec2_names)
}

resource "aws_instance" "k8s" {
    for_each = var.ec2_names
    
    ami           = var.ami_id
    instance_type = var.instance_type
    associate_public_ip_address = true
    # key_name = aws_key_pair.l8s.key_name
    # security_groups = [""]
    
    tags = {
        Name = each.value
    }
}

resource "local_file" "k8s3" {
    filename = "./scripts/nodes.txt"
    content = <<-EOT
        %{ for node in local.instances ~}
${aws_instance.k8s["${node}"].private_ip} ${var.ec2_names["${node}"]}
        %{ endfor ~}
    EOT
}