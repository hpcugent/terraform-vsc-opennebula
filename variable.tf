variable "vm_name" {
  type = string
}
variable "image_name" {
  description = "Name of the OS Image. See `oneimage list`."
}
locals {
  rootdisk_size = (var.is_windows ? max(var.rootdisk_size, 70) : var.rootdisk_size) * 1024
}
variable "rootdisk_size" {
  description = "Size of the bootdisk in Gibibyte"
  default     = 30
  type        = number
}
variable "memory" {
  description = "Memory allocated to the VM in Gibibytes"
  type        = number
  default     = null
}
variable "cpu" {
  type        = number
  description = "Real CPU cores allocated to the VM"
  default     = null
}
variable "vcpu" {
  type        = number
  description = "Virtual CPUs that the VM will see. DOES improve multi-thread performance."
  default     = null

}
variable "template" {
  description = "Template to apply to the VM. Default should be OK unless you need a GPU."
  type        = string
  default     = "TestFlavor" # To be changed
}
variable "vsc" {
  description = "Enable VSC network."
  default     = false
  type        = bool
}
variable "disks" {
  description = "List of disks to attach to the VM."
  type = map(object({
    size       = number
    filesystem = optional(string, "ext4")
  }))
  default = {}
}
variable "custom_context" {
  description = "Custom opennebula context to append to the VM."
  type        = map(string)
  default     = {}
}
variable "start_script" {
  description = "Script that runs ONCE after VM creation"
  type        = string
  default     = "echo"
  validation {
    condition     = var.is_windows ? (var.start_script == "echo") : true
    error_message = "start_script is incompatible with Windows!"
  }
}
variable "firewall_rules" {
  description = "List of firewall rules that apply to this VM. protocol (ALL|TCP|UDP|TCMP|IPSEC),range (portA,portB-portX), rule_type (INBOUND|OUTBOUND)"
  type = list(object({
    protocol  = string
    rule_type = optional(string, "INBOUND")
    range     = string
  }))
  default = []
  validation {
    condition     = length(var.firewall_rules) == 0 ? true : (anytrue([for v in var.firewall_rules : can(regex("^(INBOUND|OUTBOUND)$", v.rule_type))]))
    error_message = "rule_type must be INBOUND or OUTBOUND"
  }
  validation {
    condition     = length(var.firewall_rules) == 0 ? true : (anytrue([for v in var.firewall_rules : can(regex("^(ALL|TCP|UDP|ICMP|IPSEC)$", v.protocol))]))
    error_message = "protocol must be ALL, TCP, UDP, ICMP or IPSEC"
  }
}
variable "firewall_services" {
  description = "quick alternative to firewall_rules for known services"
  type        = list(string)
  validation {
    condition     = alltrue([for s in var.firewall_services : contains(keys(local.service-templates), s)])
    error_message = "Unknown service! Valid services: ${join(",", keys(local.service-templates))}"
  }
  default = []
}
variable "is_windows" {
  description = "Set true if image is windows based"
  type        = bool
}
