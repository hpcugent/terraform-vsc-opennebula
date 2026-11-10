variable "disk_type" {
  type = string

  validation {
    condition     = contains(["image", "disk"], var.disk_type)
    error_message = "disk_type must be one of: image, disk."
  }

  # image: size must not be set
  validation {
    condition     = var.disk_type != "image" || var.size == null
    error_message = "`size` is incompatible with disk_type `image`."
  }

  # disk: size is required
  validation {
    condition     = var.disk_type != "disk" || var.size != null
    error_message = "`size` is required for disk_type `disk`."
  }

  # disk: no image_id / image_name
  validation {
    condition     = var.disk_type != "disk" || (var.image_id == null && var.image_name == null)
    error_message = "`image_id` and `image_name` are incompatible with disk_type `disk`."
  }

  # image: exactly one of image_id / image_name
  validation {
    condition     = var.disk_type != "image" || (var.image_id == null) != (var.image_name == null)
    error_message = "disk_type `image` requires exactly one of `image_id` or `image_name`."
  }
}

variable "size" {
  type    = number
  default = null

  validation {
    condition     = var.size == null ? true : var.size > 0
    error_message = "Disk size must be bigger than 0."
  }
}

variable "image_id" {
  type        = string
  default     = null
  description = "Image ID to clone"
}

variable "image_name" {
  type        = string
  default     = null
  description = "Name of the image to clone. If multiple images exist, use `image_id` instead."
}
variable "name" {
  type        = string
  description = "name of the image"
}
variable "persistent" {
  type    = bool
  default = false
}
