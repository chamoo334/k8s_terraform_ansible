# Virtual Network
resource "azurerm_virtual_network" "k8s" {
  name                = "${var.network_name}-network"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.k8s.name
  address_space       = [var.network_address_space[0]]
  #   dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

# static ip addresses
resource "azurerm_public_ip" "k8s" {
  for_each            = var.vm_names
  name                = "${each.value}-ip"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = var.resource_group_location
  allocation_method   = "Static"
}

# Subnets
resource "azurerm_subnet" "k8s" {
  count                = 2
  name                 = count.index == 0 ? "${var.network_name}-controller-subnet" : "${var.network_name}-workers-subnet"
  resource_group_name  = azurerm_resource_group.k8s.name
  virtual_network_name = azurerm_virtual_network.k8s.name
  address_prefixes     = [var.network_address_space[count.index + 1]]
  # security_group = azurerm_network_security_group.example.id

  depends_on = [azurerm_virtual_network.k8s]
}

# Subnet Security Association
resource "azurerm_subnet_network_security_group_association" "worker" {
  count                     = 2
  subnet_id                 = azurerm_subnet.k8s[count.index].id
  network_security_group_id = count.index == 0 ? azurerm_network_security_group.controller.id : azurerm_network_security_group.worker.id
}

# Network Interfaces
resource "azurerm_network_interface" "k8s" {
  for_each            = var.vm_names
  name                = "${each.value}-nic"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.k8s.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.key == local.machines[0] ? azurerm_subnet.k8s[0].id : azurerm_subnet.k8s[1].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.k8s[each.key].id
  }

  depends_on = [azurerm_subnet.k8s, azurerm_public_ip.k8s]
}