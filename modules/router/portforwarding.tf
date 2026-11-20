variable "access_vm" {
  type = object({
    ip       = string
    vsc_ip   = string
    ssh_port = number
    command  = string
  })
  default = null
  validation {
    condition     = !var.vsc || var.access_vm == null || var.access_vm != null && (var.vsc && var.access_vm.vsc_ip != "")
    error_message = "VSC Router access VM must have `vsc = true` set! (No local vsc IP found)"
  }
}
locals {
  vm_ip = var.vsc ? try(var.access_vm.vsc_ip, null) : try(var.access_vm.ip, null)
  port_forwards_from_vm = var.access_vm == null ? {} : {
    "VM-SSH" = {
      internal_ip   = local.vm_ip
      external_port = var.access_vm.ssh_port
      internal_port = var.access_vm.ssh_port
    }
  }
  all_port_forwards = [
    for pf in concat(values(local.port_forwards_from_vm), values(var.port_forwards)) : {
      internal_ip   = coalesce(pf.internal_ip, local.vm_ip)
      internal_port = coalesce(pf.internal_port, pf.external_port)
      external_port = pf.external_port
    }
  ]
  port_forward_context = {
    for idx, pf in local.all_port_forwards :
    "ONEAPP_VNF_NAT4_PORT_FWD${idx}" =>
    format(
      "%s:%d:%s:%d",
      opennebula_virtual_router_nic.external.ip,
      pf.external_port,
      pf.internal_ip,
      pf.internal_port
    )
  }
  primary_vm_output = var.access_vm == null ? {} : { "Primary VM" = replace(var.access_vm.command, var.access_vm.ip, opennebula_virtual_router_nic.external.ip) }


}
