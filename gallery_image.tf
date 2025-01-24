resource "azurerm_shared_image_gallery" "this" {
  name                = var.gallery_name
  resource_group_name = var.resource_group
  location            = var.location
}

resource "azurerm_shared_image" "this" {
  name                              = var.image_name
  gallery_name                      = azurerm_shared_image_gallery.this.name
  resource_group_name               = var.resource_group
  location                          = var.location
  os_type                           = "Linux"
  specialized                       = false
  hyper_v_generation                = "V2"
  confidential_vm_supported         = true
  hibernation_enabled               = false
  disk_controller_type_nvme_enabled = var.image_disk_controller_type_nvme_enabled
  min_recommended_memory_in_gb      = var.image_min_recommended_memory_in_gb
  min_recommended_vcpu_count        = var.image_min_recommended_vcpu_count

  dynamic "identifier" {
    for_each = var.image_identifier[*]
    content {
      publisher = identifier.value.publisher
      offer     = identifier.value.offer
      sku       = identifier.value.sku
    }
  }
}

resource "azurerm_shared_image_version" "this" {
  for_each            = { for item in var.image_version_blob_storage_uris : item.image_version => item }
  name                = each.key
  gallery_name        = azurerm_shared_image_gallery.this.name
  image_name          = azurerm_shared_image.this.name
  resource_group_name = var.resource_group
  location            = var.location
  blob_uri            = each.value.uri
  storage_account_id  = var.blob_storage_account_id

  target_region {
    name                   = azurerm_shared_image.this.location
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }
}
