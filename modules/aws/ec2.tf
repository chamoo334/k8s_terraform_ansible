resource "aws_instance" "k8s" {
    for_each = var.ec2_names
    
    ami           = var.ami_id
    instance_type = var.instance_type
    associate_public_ip_address = true
    # key_name = ""
    # security_groups = [""]
    
    tags = {
        Name = each.value
    }

    provisioner "local-exec" {
        command = "echo ${self.private_ip} ${each.value}>> private_ips.txt"
    }
}