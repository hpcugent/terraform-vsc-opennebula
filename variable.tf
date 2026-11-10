variable "vm_name" {
  type = string
}
variable "image_name" {
  description = "Name of the OS Image. See `oneimage list`."
}
locals {
  rootdisk_size = var.rootdisk_size * 1024
}
variable "rootdisk_size" {
  description = "Size of the bootdisk in Gibibyte. Needs to be manually resized after apply."
  type        = number
  validation {
    condition     = !var.is_windows || (var.is_windows && var.rootdisk_size >= 70)
    error_message = "Windows disk should at least 70Gib!"
  }
}
variable "memory" {
  description = "Memory allocated to the VM in Gibibytes."
  type        = number
}
variable "cpu" {
  type        = number
  description = "Real CPU cores allocated to the VM"
}
variable "template" {
  description = "Template to apply to the VM. Default should be OK unless you need a GPU."
  type        = string
  default     = "UserDefault" # To be changed
}
variable "vsc" {
  description = "Enable VSC network."
  default     = false
  type        = bool
}
variable "disks" {
  description = "List of disks to attach to the VM."
  type = map(object({
    size     = optional(number)
    image_id = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, d in var.disks : (
        d.image_id != null
        ? (d.size == null)
        : (d.size != null)
      )
    ])
    error_message = "`image_id` is mutually exclusive with `size`!"
  }
}
variable "custom_context" {
  description = "Custom opennebula context to append to the VM."
  type        = map(string)
  default     = {}
}
variable "start_script" {
  description = "Script that runs every boot. Changing this value will execute the script immediately. Incompatible with Windows."
  type        = string
  default     = "echo"
  validation {
    condition     = var.is_windows ? (var.start_script == "echo") : true
    error_message = "start_script is incompatible with Windows!"
  }
}

variable "is_windows" {
  description = "Set true if image is windows based"
  type        = bool
  default     = false
}
variable "user" {
  default     = null
  description = "Username used to connect via SSH"
  type        = string
}
