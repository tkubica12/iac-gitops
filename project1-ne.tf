resource "azurerm_resource_group" "project1-ne" {
  name     = "project1-ne-rg"
  location = "norteurope"
}

module "kubernetes-project1-ne" {
  source = "./modules/kubernetes"

  resource_group  = azurerm_resource_group.project1-ne.name
  location        = azurerm_resource_group.project1-ne.location
  name            = "project1-aks-ne"
  subnet_id       = azurerm_subnet.ne-project1.id
  admin_group_id  = "2f003f7d-d039-4f87-8575-c2d45d091c2c"
  GIT_PRIVATE_KEY = var.GIT_PRIVATE_KEY
  GIT_PUBLIC_KEY  = var.GIT_PUBLIC_KEY
}
