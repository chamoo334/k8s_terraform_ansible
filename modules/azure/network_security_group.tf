# resource "azurerm_network_security_group" "k8s-controller" {
#   name                = "example-security-group"
#   location            = var.resource_group_location
#   resource_group_name = azurerm_resource_group.k8s.name
# }

# resource "azurerm_network_security_group" "k8s-worker" {
#   name                = "example-security-group"
#   location            = var.resource_group_location
#   resource_group_name = azurerm_resource_group.k8s.name
# }