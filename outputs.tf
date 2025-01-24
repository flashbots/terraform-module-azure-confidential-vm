output "vm_details" {
  value = {
    for k, vm in module.cvm : k => {
      id              = vm.vm_id
      public_ip       = vm.vm_public_ip
      security_group  = vm.security_group_id
    }
  }
  description = "Virtual Machine details"
}
