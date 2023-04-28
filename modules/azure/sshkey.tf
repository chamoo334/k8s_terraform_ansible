# RSA private key pair
resource "tls_private_key" "k8s" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# .pem for remote access via ssh
resource "local_file" "k8s_key" {
  filename        = "./ansible/azure_${var.ssh_key_name}.pem"
  file_permission = "0400"
  content         = tls_private_key.k8s.private_key_pem
}

# register key pair in AWS
resource "azurerm_ssh_public_key" "k8s" {
  name                = var.ssh_key_name
  resource_group_name = azurerm_resource_group.k8s.name
  location            = var.resource_group_location
  public_key          = tls_private_key.k8s.public_key_openssh
}