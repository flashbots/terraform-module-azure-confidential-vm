output "vm_id" {
  value       = azurerm_linux_virtual_machine.cvm.id
  description = "The ID of the virtual machine"
}

output "vm_public_ip" {
  value       = azurerm_public_ip.this.ip_address
  description = "The public IP address of the virtual machine"
}

output "security_group_id" {
  value       = module.azure_security_group_cvm.id
  description = "The ID of the security group"
}
