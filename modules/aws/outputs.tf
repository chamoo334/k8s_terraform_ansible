output "ec2_private_ips" {
    # value = {
    #     var.ec2_names = aws_instance.k8s["k8s-"].private_ip
    #     var.ec2_names = aws_instance.k8s["k8s-"].private_ip 
    #     var.ec2_names = aws_instance.k8s["k8s-"].private_ip  
    # }
    value = aws_instance.k8s.*
}