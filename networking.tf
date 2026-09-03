locals {
  main_net = "${local.group}${var.use_demo_format ? "_vm" : "-private"}"
  vsc_net  = "${local.group}${var.use_demo_format ? "_vm_vsc" : "-private-vsc"}"
}

data "opennebula_virtual_network" "main" {
  name = local.main_net
}
data "opennebula_virtual_network" "vsc" {
  name = local.vsc_net
  lifecycle {
    enabled = var.vsc
  }
}
