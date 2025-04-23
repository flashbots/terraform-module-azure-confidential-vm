resource "azurerm_linux_virtual_machine" "cvm" {
  name = var.vm_name

  location            = var.location
  resource_group_name = var.resource_group

  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.this.id]
  # Authentication for BuilderNet images does not rely on Azure's VM agent
  # but TF provider requires some values to be set anyways
  admin_username                  = "notused"
  admin_password                  = "N0tused!"
  disable_password_authentication = false
  secure_boot_enabled             = var.vm_secure_boot_enabled
  vtpm_enabled                    = var.vm_vtpm_enabled

  os_disk {
    name                     = var.vm_name
    caching                  = var.os_disk_caching
    disk_size_gb             = var.os_disk_size_gb
    storage_account_type     = "Premium_LRS"
    security_encryption_type = "VMGuestStateOnly"
  }

  source_image_id = var.source_image_id
}

resource "azurerm_managed_disk" "data" {
  name = "${var.vm_name}-data"

  location            = var.location
  resource_group_name = var.resource_group

  create_option            = "Empty"
  disk_size_gb             = var.data_disk_size_gb
  storage_account_type     = var.data_disk_storage_account_type
  performance_plus_enabled = var.data_disk_size_gb >= 512 ? var.data_disk_performance_plus_enabled : false
  tier                     = var.data_disk_tier

  lifecycle {
    ignore_changes = [
      source_resource_id,
      create_option
     ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "cvm_data" {
  virtual_machine_id = azurerm_linux_virtual_machine.cvm.id
  managed_disk_id    = azurerm_managed_disk.data.id

  caching = var.data_disk_caching_type
  lun     = var.data_disk_lun
}

resource "azurerm_network_interface" "this" {
  name = var.vm_name

  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "nic"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_public_ip" "this" {
  name = var.vm_name

  resource_group_name = var.resource_group
  location            = var.location

  allocation_method = "Static"
}

module "azure_security_group_cvm" {
  source = "../azure-security-group"

  name = var.vm_name

  location            = var.location
  resource_group_name = var.resource_group

  egress_ranges  = var.security_group_egress_ranges
  ingress_ranges = var.security_group_ingress_ranges
}

resource "azurerm_network_interface_security_group_association" "cvm_security_group" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = module.azure_security_group_cvm.id
}
