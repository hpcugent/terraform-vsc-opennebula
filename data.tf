data "opennebula_image" "image" {
  name = var.image_name
}
data "opennebula_template" "template" {
  name = var.template
}
resource "random_pet" "windows" {
  count  = var.is_windows ? 1 : 0
  length = 3
}
