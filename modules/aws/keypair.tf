resource "tls_private_key" "k8s" {
    algorithm = "RSA"
    rsa_bits = 4096

    # provisioner "local-exec" {
    #     command = "echo ${self.private_key_pem} >> ./k8s.pem"
    # }
}

resource "local_file" "k8s" {
    filename = "./scripts/${var.key_pair_name}.pem"
    file_permission = "0400"
    content = tls_private_key.k8s.private_key_pem
}

resource "aws_key_pair" "k8s" {
    key_name = var.key_pair_name
    public_key = tls_private_key.k8s.public_key_openssh
}