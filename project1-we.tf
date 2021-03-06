resource "azurerm_resource_group" "project1-we" {
  name     = "project1-we-rg"
  location = "westeurope"
}

module "kubernetes-project1-we" {
  source = "./modules/kubernetes"

  resource_group  = azurerm_resource_group.project1-we.name
  location        = azurerm_resource_group.project1-we.location
  name            = "project1-aks-we"
  subnet_id       = azurerm_subnet.we-project1.id
  admin_group_id  = "2f003f7d-d039-4f87-8575-c2d45d091c2c"
  GIT_PRIVATE_KEY = var.GIT_PRIVATE_KEY
  GIT_PUBLIC_KEY  = var.GIT_PUBLIC_KEY
}
