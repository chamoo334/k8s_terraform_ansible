# RSA private key pair
resource "tls_private_key" "k8s" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# .pem for remote access via ssh
resource "local_file" "k8s_key" {
  filename        = "./ansible/gcp_${var.ssh_key_name}.pem"
  file_permission = "0400"
  content         = tls_private_key.k8s.private_key_pem
}