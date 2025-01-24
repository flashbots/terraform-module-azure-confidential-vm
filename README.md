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
| terraform | >= 1.0 |
| azurerm | ~> 4.14.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.14.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| blob\_storage\_account\_id | Resource ID of the storage account containing VM image blobs | `string` | n/a | yes |
| data\_disk\_caching\_type | Caching strategy for the data disk (None, ReadOnly, ReadWrite) | `string` | `"ReadOnly"` | no |
| data\_disk\_lun | Logical Unit Number (LUN) for the data disk attachment | `number` | `10` | no |
| data\_disk\_performance\_plus\_enabled | Enable performance plus tier for the data disk, offering better performance for Premium\_LRS disks | `bool` | `true` | no |
| data\_disk\_size\_gb | Size of the additional data disk in gigabytes | `string` | n/a | yes |
| data\_disk\_storage\_account\_type | Storage account type for the data disk. Premium\_LRS recommended for better performance | `string` | `"Premium_LRS"` | no |
| data\_disk\_tier | Performance tier for the data disk. Leave as null for automatic tier selection | `string` | `null` | no |
| gallery\_name | Name of the Azure Shared Image Gallery for storing VM images | `string` | `"confidential_vm_images"` | no |
| image\_disk\_controller\_type\_nvme\_enabled | Enable NVMe disk controller for the shared image | `bool` | `true` | no |
| image\_identifier | Identifier information for the shared image in Azure Marketplace format | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>  })</pre> | <pre>{<br>  "offer": "BuilderNet",<br>  "publisher": "ACME, Inc.",<br>  "sku": "builder"<br>}</pre> | no |
| image\_min\_recommended\_memory\_in\_gb | Minimum recommended memory in GB for VMs created from this image | `number` | `32` | no |
| image\_min\_recommended\_vcpu\_count | Minimum recommended vCPU count for VMs created from this image | `number` | `8` | no |
| image\_name | Name of the shared image in the gallery | `string` | `"builder"` | no |
| image\_version\_blob\_storage\_uris | List of image versions and their corresponding blob storage URIs for VM images | <pre>list(object({<br>    image_version = string<br>    uri           = string<br>  }))</pre> | n/a | yes |
| location | The Azure region where all resources will be created | `string` | n/a | yes |
| os\_disk\_caching | Caching strategy for the OS disk (None, ReadOnly, ReadWrite) | `string` | `"ReadWrite"` | no |
| os\_disk\_size\_gb | Size of the OS disk in gigabytes | `number` | `16` | no |
| resource\_group | The name of the Azure resource group where all resources will be deployed | `string` | n/a | yes |
| security\_group\_egress\_ranges | Egress rules for the network security group. See ./modules/azure-security-group/variables.tf for the format | `map(list(string))` | `{}` | no |
| security\_group\_ingress\_ranges | Ingress rules for the network security group. See ./modules/azure-security-group/variables.tf for the format | `map(list(string))` | `{}` | no |
| subnet\_id | Resource ID of the subnet where the VM's network interface will be created | `string` | n/a | yes |
| vm\_image\_version | Version of the VM image to use from the shared image gallery. Use 'latest' for most recent version | `string` | `"latest"` | no |
| vm\_name | Base name for the VM and associated resources (disks, NICs, etc.) | `string` | `"builder"` | no |
| vm\_secure\_boot\_enabled | Enable secure boot for the VM | `bool` | `false` | no |
| vm\_size | Azure VM size/type | `string` | `"Standard_EC16es_v5"` | no |
| vm\_vtpm\_enabled | Enable virtual TPM for the VM | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_id | The ID of the security group |
| vm\_id | The ID of the virtual machine |
| vm\_public\_ip | The public IP address of the virtual machine |

## Note for contributors
Make sure to use [terraform-docs](https://github.com/terraform-docs/terraform-docs) to generate the configuration parameters of the module (provider requirements, input variables, outputs) should you update them.
