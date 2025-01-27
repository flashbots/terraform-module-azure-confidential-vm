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
    storage_account_type   = "Premium_LRS"
  }
}

module "cvm" {
  source = "./modules/azure-confidential-vm"

  for_each = var.vms

  location       = var.location
  resource_group = var.resource_group

  vm_name                            = each.key
  source_image_id                    = azurerm_shared_image_version.this[each.value.image_version].id
  vm_size                            = each.value.size
  vm_secure_boot_enabled             = each.value.secure_boot_enabled
  vm_vtpm_enabled                    = each.value.vtpm_enabled
  os_disk_caching                    = each.value.os_disk_caching
  os_disk_size_gb                    = each.value.os_disk_size_gb
  data_disk_size_gb                  = each.value.data_disk_size_gb
  data_disk_storage_account_type     = each.value.data_disk_storage_account_type
  data_disk_performance_plus_enabled = each.value.data_disk_performance_plus_enabled
  data_disk_tier                     = each.value.data_disk_tier
  data_disk_caching_type             = each.value.data_disk_caching_type
  data_disk_lun                      = each.value.data_disk_lun
  subnet_id                          = each.value.subnet_id
  security_group_egress_ranges       = each.value.security_group_egress_ranges
  security_group_ingress_ranges      = each.value.security_group_ingress_ranges
}
