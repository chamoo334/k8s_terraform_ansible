# General project information
cloud_provider = {
  aws   = false
  azure = false
  gcp   = false
}
project_id = ""

# AWS variables
aws = {
  creds = {
    region     = ""
    access_key = ""
    secret_key = ""
  }
  ami_id        = ""
  instance_type = ""
}

# Azure variables
azure = {
  creds = {
    subscription_id = ""
    tenant_id       = ""
    client_id       = ""
    client_secret   = ""
  }
  resource_group_location         = ""
  address_space                   = ["", "", ""]
  vm_size                         = ""
  disable_password_authentication = true
  admin_username                  = ""
  source_image = {
    publisher = ""
    offer     = ""
    sku       = ""
    version   = ""
  }
}

# GCP variables
gcp = {
  creds = {
    project     = ""
    region      = ""
    zone        = ""
    credentials = ""
  }
  network        = ""
  machine_type   = ""
  image          = ""
  admin_username = ""
}
