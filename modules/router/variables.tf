variable "start_script" {
  description = "Script that runs -only once- upon creation of virtual router VMs"
  type        = string
  default     = <<EOF
#!/bin/bash
iptables -t nat -A POSTROUTING -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
EOF
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
  description = "List of port forwarding rules."
}
