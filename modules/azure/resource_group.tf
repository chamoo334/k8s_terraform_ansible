resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.resource_group_location
}