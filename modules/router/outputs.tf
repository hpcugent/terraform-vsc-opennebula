output "router-ip" {
  description = "Outputs the external IP of the router"
  value       = opennebula_virtual_router_nic.external.ip
}
output "services_list" {
  description = "Outputs the services that the router exposes"
  value = merge(
    { "Primary VM" = local.primary_vm_output },
    { for name, svc in var.port_forwards :
      "${name}" => "${opennebula_virtual_router_nic.external.ip}:${svc.external_port}"
    }
  )
}
