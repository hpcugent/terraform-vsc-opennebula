locals {
  main_net = "${local.group}_${var.use_demo_format ? "vm" : "internal"}"
  vsc_net = "${local.group}_${var.use_demo_format ? "vm" : "internal_vsc"}"
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
