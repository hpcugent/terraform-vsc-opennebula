variable "port_forwards" {
  type = map(object({
    internal_ip   = optional(string)
    internal_port = optional(number)
    external_port = number
  }))
  default = {}
  validation {
    condition = (
      alltrue([
        for v in var.port_forwards :
        (
          v.network == "vsc" || v.external_port == 80 || v.external_port == 443 ||
          (
            v.external_port >= local.ugent_port_range.min &&
            v.external_port <= local.ugent_port_range.max
          )
        )
      ])
    )
    error_message = "External port must be 80, 443, or between ${local.ugent_port_range.min} and ${local.ugent_port_range.max}."
  }
  description = "List of port forwarding rules. Map of objects with following attributes: external_port (required), internal_port, internal_ip"
}

variable "group" {
  default     = ""
  description = "Opennebula group to create this router for. There should only be ONE router per group."
  type        = string
}
variable "vsc" {
  default     = false
  description = "Enable to connect the router to the VSC network. Only ONE per group and you need to have requested access to the VSC network."
  type        = bool
}
