locals {
  main_net = "${data.opennebula_group.group.name}-private"
  vsc_net  = "${data.opennebula_group.group.name}-private-vsc"
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
