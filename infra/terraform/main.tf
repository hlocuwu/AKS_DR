resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

resource "azurerm_resource_group" "primary_rg" {
  name     = "${var.project_name}-primary-rg"
  location = var.primary_location
}

resource "azurerm_resource_group" "secondary_rg" {
  name     = "${var.project_name}-secondary-rg"
  location = var.secondary_location
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${replace(var.project_name, "-", "")}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.primary_rg.name
  location            = azurerm_resource_group.primary_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_public_ip" "primary_ip" {
  name                = "aks-primary-ingress-ip"
  resource_group_name = azurerm_resource_group.primary_rg.name
  location            = azurerm_resource_group.primary_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.project_name}-pri-${random_string.suffix.result}"
  
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_public_ip" "secondary_ip" {
  name                = "aks-secondary-ingress-ip"
  resource_group_name = azurerm_resource_group.secondary_rg.name
  location            = azurerm_resource_group.secondary_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.project_name}-sec-${random_string.suffix.result}"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_kubernetes_cluster" "primary_aks" {
  name                = "${var.project_name}-primary-aks"
  location            = azurerm_resource_group.primary_rg.location
  resource_group_name = azurerm_resource_group.primary_rg.name
  dns_prefix          = "${var.project_name}-primary"
  sku_tier            = "Free"

  default_node_pool {
    name       = "agentpool"
    node_count = 1
    vm_size    = "Standard_B2s_v2" 
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster" "secondary_aks" {
  name                = "${var.project_name}-secondary-aks"
  location            = azurerm_resource_group.secondary_rg.location
  resource_group_name = azurerm_resource_group.secondary_rg.name
  dns_prefix          = "${var.project_name}-secondary"
  sku_tier            = "Free"

  default_node_pool {
    name       = "agentpool"
    node_count = 1
    vm_size    = "Standard_B2s_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "primary_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.primary_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "secondary_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.secondary_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "${var.project_name}-tm-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.primary_rg.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "${var.project_name}-tm-${random_string.suffix.result}"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "primary_endpoint" {
  name               = "primary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.tm.id
  priority           = 1
  weight             = 100
  target_resource_id = azurerm_public_ip.primary_ip.id
}

resource "azurerm_traffic_manager_azure_endpoint" "secondary_endpoint" {
  name               = "secondary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.tm.id
  priority           = 2
  weight             = 100
  target_resource_id = azurerm_public_ip.secondary_ip.id
}