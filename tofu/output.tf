output "Master-IPS" {
  value = [
    for instance in proxmox_virtual_environment_vm.proxmox_vm_master : instance.ipv4_addresses[1][0]
  ]
}

output "worker-IPS" {
  value = [
    for instance in proxmox_virtual_environment_vm.proxmox_vm_workers : instance.ipv4_addresses[1][0]
  ]
}
