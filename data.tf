data "opennebula_user" "me" {
  id = -1
}
data "opennebula_group" "group" {
  id = -1
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
