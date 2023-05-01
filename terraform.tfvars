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
ami_id        = ""
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
disable_password_authentication = false
source_image = {
  publisher = ""
  offer     = ""
  sku       = ""
  version   = ""
}

# gcp_credentials = {}