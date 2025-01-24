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

variable "vms" {
  type = map(object({
    size                               = optional(string)
    image_version                      = optional(string, "latest")
    secure_boot_enabled                = optional(bool)
    vtpm_enabled                       = optional(bool)
    os_disk_caching                    = optional(string)
    os_disk_size_gb                    = optional(number)
    data_disk_size_gb                  = string
    data_disk_storage_account_type     = optional(string)
    data_disk_performance_plus_enabled = optional(bool)
    data_disk_tier                     = optional(string)
    data_disk_caching_type             = optional(string)
    data_disk_lun                      = optional(number)
    subnet_id                          = string
    security_group_egress_ranges       = optional(map(list(string)))
    security_group_ingress_ranges      = optional(map(list(string)))
  }))
  description = "Virtual machine configurations"
}
