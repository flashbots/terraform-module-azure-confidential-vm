variable "location" {
  type        = string
  description = "The Azure region where all resources will be created"
}

variable "resource_group" {
  type        = string
  description = "The name of the Azure resource group where all resources will be deployed"
}

variable "gallery_name" {
  type        = string
  description = "Name of the Azure Shared Image Gallery for storing VM images"
  default     = "confidential_vm_images"
}

variable "image_name" {
  type        = string
  description = "Name of the shared image in the gallery"
  default     = "builder"
}

variable "image_disk_controller_type_nvme_enabled" {
  type        = bool
  description = "Enable NVMe disk controller for the shared image"
  default     = true
}

variable "image_min_recommended_memory_in_gb" {
  type        = number
  description = "Minimum recommended memory in GB for VMs created from this image"
  default     = 32
}

variable "image_min_recommended_vcpu_count" {
  type        = number
  description = "Minimum recommended vCPU count for VMs created from this image"
  default     = 8
}

variable "image_identifier" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
  })
  description = "Identifier information for the shared image in Azure Marketplace format"
  default = {
    publisher = "ACME, Inc."
    offer     = "BuilderNet"
    sku       = "builder"
  }
}

variable "blob_storage_account_id" {
  type        = string
  description = "Resource ID of the storage account containing VM image blobs"
}

variable "image_version_blob_storage_uris" {
  type = list(object({
    image_version = string
    uri           = string
  }))
  description = "List of image versions and their corresponding blob storage URIs for VM images"
}

variable "vm_image_version" {
  type        = string
  description = "Version of the VM image to use from the shared image gallery. Use 'latest' for most recent version"
  default     = "latest"
}

variable "vm_name" {
  type        = string
  description = "Base name for the VM and associated resources (disks, NICs, etc.)"
  default     = "builder"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size/type"
  default     = "Standard_EC16es_v5"
}

variable "vm_secure_boot_enabled" {
  type        = bool
  description = "Enable secure boot for the VM"
  default     = false
}

variable "vm_vtpm_enabled" {
  type        = bool
  description = "Enable virtual TPM for the VM"
  default     = true
}

variable "os_disk_caching" {
  type        = string
  description = "Caching strategy for the OS disk (None, ReadOnly, ReadWrite)"
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be one of: None, ReadOnly, ReadWrite"
  }
}

variable "os_disk_size_gb" {
  type        = number
  description = "Size of the OS disk in gigabytes"
  default     = 16
}

variable "data_disk_size_gb" {
  type        = string
  description = "Size of the additional data disk in gigabytes"
}

variable "data_disk_storage_account_type" {
  type        = string
  description = "Storage account type for the data disk. Premium_LRS recommended for better performance"
  default     = "Premium_LRS"
}

variable "data_disk_performance_plus_enabled" {
  type        = bool
  description = "Enable performance plus tier for the data disk, offering better performance for Premium_LRS disks"
  default     = true
}

variable "data_disk_tier" {
  type        = string
  description = "Performance tier for the data disk. Leave as null for automatic tier selection"
  default     = null
}

variable "data_disk_caching_type" {
  type        = string
  description = "Caching strategy for the data disk (None, ReadOnly, ReadWrite)"
  default     = "ReadOnly"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.data_disk_caching_type)
    error_message = "Data disk caching must be one of: None, ReadOnly, ReadWrite"
  }
}

variable "data_disk_lun" {
  type        = number
  description = "Logical Unit Number (LUN) for the data disk attachment"
  default     = 10

  validation {
    condition     = var.data_disk_lun >= 0 && var.data_disk_lun <= 63
    error_message = "LUN must be between 0 and 63"
  }
}

variable "subnet_id" {
  type        = string
  description = "Resource ID of the subnet where the VM's network interface will be created"
}

variable "security_group_egress_ranges" {
  type        = map(list(string))
  description = "Egress rules for the network security group. See ./modules/azure-security-group/variables.tf for the format"
  default     = {}
}

variable "security_group_ingress_ranges" {
  type        = map(list(string))
  description = "Ingress rules for the network security group. See ./modules/azure-security-group/variables.tf for the format"
  default     = {}
}
