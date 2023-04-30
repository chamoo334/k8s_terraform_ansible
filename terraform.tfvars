cloud_provider = {
  "aws"   = false
  "azure" = false
  "gcp"   = false
}

aws_credentials = {
  "region"     = ""
  "access_key" = ""
  "secret_key" = ""
}
ami_id        = "ami-06e46074ae430fba6"
instance_type = ""

azure_credentials = {
  subscription_id = ""
  tenant_id       = ""
  client_id       = ""
  client_secret   = ""
}
resource_group_location = ""
azure_address_space = ["", "", ""]
vm_size = ""
admin_username = ""
disable_password_authentication = true
source_image = {
  publisher = ""
  offer     = ""
  sku       = ""
  version   = ""
}