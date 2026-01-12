locals {
  ugent_port_range = {
    min = 51001
    max = 59999
  }
}
variable "port_forwards" {
  type = map(object({
    internal_ip   = optional(string)
    internal_port = optional(number)
    external_port = number
  }))
  default = {}
  validation {
    condition = (
      length(var.port_forwards) == 0 ? true :
      alltrue([
        for v in var.port_forwards :
        (
          v.external_port == 80 || v.external_port == 443 ||
          (
            v.external_port >= local.ugent_port_range.min &&
            v.external_port <= local.ugent_port_range.max
          )
        )
      ])
    )
    error_message = "External port must be 80, 443, or between ${local.ugent_port_range.min} and ${local.ugent_port_range.max}."
  }
  description = <<-EOF
  List of port forwarding rules.
  internal_ip (optional) default: access_vm IP
  internal_port (optional) default: external_port
  external_port (required) MUST be between 51001 and 59999 OR port 80/443
EOF
}
variable "access_vm" {
  type = object({
    ip          = string
    ssh_port    = number
    rdp_port    = optional(number)
    include_rdp = bool
    commands    = list(string)
  })
  default = null
}
locals {
  port_forwards_from_vms = merge(
    { "${local.router-name}-ssh" = {
      internal_ip   = var.access_vm.ip
      external_port = var.access_vm.ssh_port
      internal_port = var.access_vm.ssh_port
    } },
    var.access_vm.include_rdp ? {
      "${local.router-name}-rdp" = {
        internal_ip   = var.access_vm.ip
        external_port = var.access_vm.rdp_port
        internal_port = var.access_vm.rdp_port
      }
    } : {}
  )
  all_port_forwards = [
    for pf in concat(values(local.port_forwards_from_vms), values(var.port_forwards)) : {
      internal_ip   = coalesce(pf.internal_ip, var.access_vm.ip)
      internal_port = coalesce(pf.internal_port, pf.external_port)
      external_port = pf.external_port
      external_ip   = "<ETH0_EP0>"
    }
  ]
  port_forward_context = {
    for idx, pf in local.all_port_forwards :
    "ONEAPP_VNF_NAT4_PORT_FWD${idx}" =>
    format(
      "%s:%d:%s:%d",
      pf.external_ip,
      pf.external_port,
      pf.internal_ip,
      pf.internal_port
    )
  }
  primary_vm_output = [
    for command in var.access_vm.commands :
    replace(command, var.access_vm.ip, opennebula_virtual_router_nic.external.ip)
  ]

}

output "services_list" {
  value = merge(
    { "Primary VM" = local.primary_vm_output },
    { for name, svc in var.port_forwards :
      "${name}" => "${opennebula_virtual_router_nic.external.ip}:${svc.external_port}"
    }
  )
}
