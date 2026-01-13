output "ssh" {
  description = "SSH Command to use for connecting. (local IP)"
  value       = local.ssh-command
}
output "rdp" {
  description = "RDP Command to use for connecting. (local IP)"
  value       = local.rdp-command
}
output "ip" {
  description = "Local VM IP."
  value       = opennebula_virtual_machine.main.ip
}
output "router_access" {
  description = "Returns information for the router module."
  value = {
    ip          = opennebula_virtual_machine.main.ip
    include_rdp = var.is_windows
    ssh_port    = local.ports.ssh
    rdp_port    = local.ports.rdp
    vm_name     = var.vm_name
    commands    = compact([local.ssh-command, local.rdp-command])
  }
}
locals {
  ssh-user = var.is_windows ? "Admin" : "root"
  ports = {
    ssh   = 22
    http  = 80
    https = 443
    rdp   = 3389
  }
  ssh-command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J snorlax ${local.ssh-user}@${opennebula_virtual_machine.main.ip}"
  rdp-command = var.is_windows ? "ssh -A snorlax -fL 3389:${opennebula_virtual_machine.main.ip}:3389 sleep 2;xfreerdp /dynamic-resolution /v:127.0.0.1 /p:${random_pet.windows[0].id} /u:admin" : ""
}
