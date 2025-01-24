Terraform module to deploy Confidential Virtual Machines on Azure, supporting both Intel TDX and AMD SEV-SNP secure execution environments.

The module focuses on deploying VMs for [BuilderNet](https://buildernet.org/) using custom images and does not support [Azure VM Agent](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/agent-linux) functionality. I.e., no cloud-init, disabled credentials passthrough, etc.

## Overview
The module handles the following infrastructure components:

- Creates an Azure Compute Gallery;
- Imports a custom VM image from Azure Blob Storage;
- Deploys a Confidential VM using the imported image.

## Prerequisites
Before using this module, you must:

- Set up an Azure Blob Storage account and create a Container;
- Upload your VM image to the Blob Storage Container;
- Obtain the blob URI for your image.

## Important Notes
The module does not create or manage the Azure Blob Storage infrastructure. You are responsible for setting up and maintaining the storage account where your VM image resides.

## Usage
Refer to the [examples](./examples/) directory for detailed configuration examples.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1 |
| azurerm | ~> 4.14.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.14.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| blob\_storage\_account\_id | Resource ID of the storage account containing VM image blobs | `string` | n/a | yes |
| gallery\_name | Name of the Azure Shared Image Gallery for storing VM images | `string` | `"confidential_vm_images"` | no |
| image\_disk\_controller\_type\_nvme\_enabled | Enable NVMe disk controller for the shared image | `bool` | `true` | no |
| image\_identifier | Identifier information for the shared image in Azure Marketplace format | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>  })</pre> | <pre>{<br>  "offer": "BuilderNet",<br>  "publisher": "ACME, Inc.",<br>  "sku": "builder"<br>}</pre> | no |
| image\_min\_recommended\_memory\_in\_gb | Minimum recommended memory in GB for VMs created from this image | `number` | `32` | no |
| image\_min\_recommended\_vcpu\_count | Minimum recommended vCPU count for VMs created from this image | `number` | `8` | no |
| image\_name | Name of the shared image in the gallery | `string` | `"builder"` | no |
| image\_version\_blob\_storage\_uris | List of image versions and their corresponding blob storage URIs for VM images | <pre>list(object({<br>    image_version = string<br>    uri           = string<br>  }))</pre> | n/a | yes |
| location | The Azure region where all resources will be created | `string` | n/a | yes |
| resource\_group | The name of the Azure resource group where all resources will be deployed | `string` | n/a | yes |
| vms | Virtual machine configurations | <pre>map(object({<br>    size                               = optional(string)<br>    image_version                      = optional(string, "latest")<br>    secure_boot_enabled                = optional(bool)<br>    vtpm_enabled                       = optional(bool)<br>    os_disk_caching                    = optional(string)<br>    os_disk_size_gb                    = optional(number)<br>    data_disk_size_gb                  = string<br>    data_disk_storage_account_type     = optional(string)<br>    data_disk_performance_plus_enabled = optional(bool)<br>    data_disk_tier                     = optional(string)<br>    data_disk_caching_type             = optional(string)<br>    data_disk_lun                      = optional(number)<br>    subnet_id                          = string<br>    security_group_egress_ranges       = optional(map(list(string)))<br>    security_group_ingress_ranges      = optional(map(list(string)))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_ids | The IDs of the security groups |
| vm\_ids | The IDs of the virtual machines |
| vm\_public\_ips | The public IP addresses of the virtual machines |

## Note for contributors
Make sure to use [terraform-docs](https://github.com/terraform-docs/terraform-docs) to generate the configuration parameters of the module (provider requirements, input variables, outputs) should you update them.
