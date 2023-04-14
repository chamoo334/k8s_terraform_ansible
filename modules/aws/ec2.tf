# resource "aws_instance" "k8s" {
#     for_each = var.ec2_names
    
#     ami           = var.ami_id
#     instance_type = var.instance_type
#     associate_public_ip_address = true
#     key_name = aws_key_pair.l8s.key_name
#     # security_groups = [""]
    
#     tags = {
#         Name = each.value
#     }

#     provisioner "local-exec" {
#         command = "echo ${self.private_ip} ${each.value}>> ./scripts/private_ips.txt"
#     }
# 
#    # provisioner "local-exec" {
#    #     interpreter = ["Powershell", "-Command"]
#    #     command = <<EOT
#    #         $ip_info = 
#    #         $current_dir = (Get-Location).Path
#    #         $ip_file = Write-Host "$(current_dir\scripts\private_ips.txt"
#    #         $ip_info | Out-File -Filepath $ip_file -Append
#    #     EOT
#    # }
# }