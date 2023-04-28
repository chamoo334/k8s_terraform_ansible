resource "azurerm_network_security_group" "controller" {
    name                = "k8s-controller-sg"
    location            = var.resource_group_location
    resource_group_name = azurerm_resource_group.k8s.name

    dynamic "security_rule" {
        for_each = var.sg_k8s_controller
        content {
            name = "${security_rule.value.name}-in"
            description = "${security_rule.value.description}-in"
            priority = security_rule.value.priority
            direction = "Inbound"
            access = "Allow"
            protocol = security_rule.value.protocol
            source_port_range           = security_rule.value.source_port_range
            destination_port_range      = security_rule.value.destination_port_range
            source_address_prefix       = "*"
            destination_address_prefix  = "*"
        }
    }

    dynamic "security_rule" {
        for_each = var.sg_k8s_controller
        content {
            name = "${security_rule.value.name}-eg"
            description = "${security_rule.value.description}-eg"
            priority = security_rule.value.priority + 1
            direction = "Outbound"
            access = "Allow"
            protocol = security_rule.value.protocol
            source_port_range           = security_rule.value.source_port_range
            destination_port_range      = security_rule.value.destination_port_range
            source_address_prefix       = "*"
            destination_address_prefix  = "*"
        }
    }
}

resource "azurerm_network_security_group" "worker" {
    name                = "k8s-worker-sg"
    location            = var.resource_group_location
    resource_group_name = azurerm_resource_group.k8s.name

    dynamic "security_rule" {
        for_each = var.sg_k8s_worker
        content {
            name = "${security_rule.value.name}-in"
            description = "${security_rule.value.description}-in"
            priority = security_rule.value.priority
            direction = "Inbound"
            access = "Allow"
            protocol = security_rule.value.protocol
            source_port_range           = security_rule.value.source_port_range
            destination_port_range      = security_rule.value.destination_port_range
            source_address_prefix       = "*"
            destination_address_prefix  = "*"
        }
    }

    dynamic "security_rule" {
        for_each = var.sg_k8s_worker
        content {
            name = "${security_rule.value.name}-eg"
            description = "${security_rule.value.description}-eg"
            priority = security_rule.value.priority + 1
            direction = "Outbound"
            access = "Allow"
            protocol = security_rule.value.protocol
            source_port_range           = security_rule.value.source_port_range
            destination_port_range      = security_rule.value.destination_port_range
            source_address_prefix       = "*"
            destination_address_prefix  = "*"
        }
    }
}

resource "azurerm_subnet_network_security_group_association" "controller" {
    subnet_id = azurerm_subnet.k8s[0].id
    network_security_group_id = azurerm_network_security_group.controller.id
}

resource "azurerm_subnet_network_security_group_association" "worker" {
    subnet_id = azurerm_subnet.k8s[1].id
    network_security_group_id = azurerm_network_security_group.worker.id
}
