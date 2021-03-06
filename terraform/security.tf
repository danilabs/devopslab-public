# Security group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

resource "azurerm_network_security_group" "mySecGroup" {
  name                = "basictraffic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Acceso a servicio SSH (default 22)
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Acceso a servicio web (default 80)
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "CP2"
  }
}

# Vinculamos el security group al interface de red
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "mySecGroupAssociationWorkers" {
  network_interface_id      = azurerm_network_interface.myNicWorkers[count.index].id
  network_security_group_id = azurerm_network_security_group.mySecGroup.id
  count                     = length(var.vm_workers)
}

resource "azurerm_network_interface_security_group_association" "mySecGroupAssociationMaster" {
  network_interface_id      = azurerm_network_interface.myNicMaster[count.index].id
  network_security_group_id = azurerm_network_security_group.mySecGroup.id
  count                     = length(var.vm_master)
}
