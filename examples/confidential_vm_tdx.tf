terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "confidential-vm-example"
  location = "eastus2"
}

resource "azurerm_virtual_network" "example" {
  name                = "confidential-vm-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "confidential-vm-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a storage account for VM images
resource "azurerm_storage_account" "example" {
  name                     = "confvmimagestest"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "images"
  storage_account_id    = azurerm_storage_account.example.id
  container_access_type = "private"
}

locals {
  vms = {
    confidential-vm = {
      image_version       = "1.0.0"
      size                = "Standard_EC2es_v5"
      secure_boot_enabled = false
      vtpm_enabled        = true
      os_disk_caching     = "ReadOnly"
      os_disk_size_gb     = 16
      data_disk_size_gb   = 256
      subnet_id           = azurerm_subnet.example.id
      security_group_ingress_ranges = {
        "  443 | tcp | orderflow reception" = ["*"]
        " 3535 | tcp | system-api"          = ["*"]
        " 5544 | tcp | orderflow reception" = ["*"]
        " 7936 | tcp | cvm proxy server"    = ["*"]
        " 9000 | tcp | lighthouse p2p"      = ["*"]
        " 9000 | udp | lighthouse p2p"      = ["*"]
        "30303 | tcp | reth p2p"            = ["*"]
        "30303 | udp | reth p2p"            = ["*"]
        "40192 | tcp | ssh"                 = ["*"]
      }
      security_group_egress_ranges = {
        "* | * | all" = ["*"]
      }
    }
  }
}

module "cvm" {
  source = "../"

  location       = azurerm_resource_group.example.location
  resource_group = azurerm_resource_group.example.name

  # Gallery configuration
  gallery_name = "prod_confidential_vm_gallery"
  image_identifier = {
    publisher = "MyCompany"
    offer     = "BuilderNet"
    sku       = "builder"
  }

  # Image version configuration
  blob_storage_account_id = azurerm_storage_account.example.id
  image_version_blob_storage_uris = [
    {
      image_version = "1.0.0"
      uri           = "${azurerm_storage_account.example.primary_blob_endpoint}images/confidential-vm-1.0.0.wic.vhd"
    }
  ]

  # VMs configuration
  vms = local.vms
}

output "vm_details" {
  value = module.cvm.vm_details
}
