resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  address_prefixes     = ["10.0.0.0/19"]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  address_prefixes     = ["10.0.32.0/19"]
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}


resource "azurerm_subnet_network_security_group_association" "subnet1_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "subnet2_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}


# If you want to use existing subnet
# data "azurerm_subnet" "subnet1" {
#   name                 = "subnet1"
#   virtual_network_name = "main"
#   resource_group_name  = "tutorial"
# }

# output "subnet_id" {
#   value = data.azurerm_subnet.subnet1.id
# }
