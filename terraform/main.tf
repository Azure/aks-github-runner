terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.66.0"
    }
  }
  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_resource_group" "group" {
  name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = var.agents_count
    vm_size    = var.agents_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Dev"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.cluster_name
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  sku                 = "Basic"
  admin_enabled       = false
}

variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "agents_size" {
  type = string
  default = "Standard_D2_v2"
}

variable "agents_count" {
  type = string
  default = "2"
}

variable "kubernetes_version" {
  type = string
  default = "1.21.2"
}
