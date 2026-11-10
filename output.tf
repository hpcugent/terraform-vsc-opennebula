output "ssh" {
  description = "SSH Command to use for connecting. (local IP)"
  value       = local.ssh-command
}
output "ip" {
  description = "Local VM IP."
  value       = opennebula_virtual_machine.main.ip
}
output "vsc_ip" {
  description = "VSC IP"
  value = var.vsc ? [
    for nic in opennebula_virtual_machine.main.nic :
  nic.computed_ip if nic.network_id == data.opennebula_virtual_network.vsc.id][0] : null
}
output "router_access" {
  description = "Returns information for the router module."
  value = {
    ip          = opennebula_virtual_machine.main.ip
    include_rdp = var.is_windows
    ssh_port    = local.ports.ssh
    vm_name     = var.vm_name
    command     = local.ssh-command
  }
}
output "windows_password" {
  value     = try(random_pet.windows.id, null)
  sensitive = true
}
locals {
  ssh-user = var.is_windows ? coalesce(var.user, "Admin") : coalesce(var.user, "root")
  ports = {
    ssh   = 22
    http  = 80
    https = 443
    rdp   = 3389
  }
  ssh-command = "ssh ${local.ssh-user}@${opennebula_virtual_machine.main.ip}"
}
