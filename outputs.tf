output "aws_ec2_ssh_commands" {
    value = module.aws_k8s[0].ssh_commands
}