# Networking

# Resource Group
resource "azurerm_resource_group" "net" {
  name     = "networking-rg"
  location = "westeurope"
}

# VNETs
resource "azurerm_virtual_network" "we" {
  name                = "my-vnet-we"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.net.name
}

resource "azurerm_virtual_network" "ne" {
  name                = "my-vnet-ne"
  address_space       = ["10.1.0.0/16"]
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.net.name
}


# Subnets
resource "azurerm_subnet" "we-project1" {
  name                 = "project1"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.we.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "we-project2" {
  name                 = "project2"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.we.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "we-project3" {
  name                 = "project3"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.we.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "we-project4" {
  name                 = "project4"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.we.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "ne-project1" {
  name                 = "project1"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.ne.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "ne-project2" {
  name                 = "project2"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.ne.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "ne-project3" {
  name                 = "project3"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.ne.name
  address_prefixes     = ["10.1.3.0/24"]
}

resource "azurerm_subnet" "ne-project4" {
  name                 = "project4"
  resource_group_name  = azurerm_resource_group.net.name
  virtual_network_name = azurerm_virtual_network.ne.name
  address_prefixes     = ["10.1.4.0/24"]
}

