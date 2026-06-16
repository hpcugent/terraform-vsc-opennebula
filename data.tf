variable "use_demo_format" {
  type = bool
  default = true
  description = "Use VSC demo project format. Only change for dev purposes."
}
locals {
  group = var.use_demo_format ? data.opennebula_group.primary.name : replace(data.opennebula_user.me,"_admin","")
}

data "opennebula_user" "me" {
  name = chomp(split(":", file("~/.one/one_auth"))[0])
}
data "opennebula_group" "primary" {
  name = var.group != "" ? var.group : null
  id   = var.group == "" ? data.opennebula_user.me.primary_group : null
}

data "opennebula_image" "image" {
  name = var.image_name
}
data "opennebula_template" "template" {
  name = var.template
}
resource "random_pet" "windows" {
  length = 3
  lifecycle {
    enabled = var.is_windows
  }
}
