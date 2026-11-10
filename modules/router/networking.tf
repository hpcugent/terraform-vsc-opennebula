locals {
  vm_network_suffix     = var.vsc ? "-private-vsc" : "-private"
  public_network_suffix = var.vsc ? "vsc" : "public"

  public_net = var.vsc ? "vsc" : "public"
  vm_net     = "${data.opennebula_group.group.name}${local.vm_network_suffix}"
}

data "opennebula_virtual_network" "external" {
  name = local.public_net
}

data "opennebula_virtual_network" "internal" {
  name = local.vm_net
}

resource "opennebula_virtual_router_nic" "external" {
  floating_ip       = true
  floating_only     = true
  virtual_router_id = opennebula_virtual_router.main.id
  network_id        = data.opennebula_virtual_network.external.id
  depends_on        = [opennebula_virtual_router_nic.internal]
  model             = "virtio"
}

data "opennebula_virtual_network_address_range" "internal" {
  virtual_network_id = data.opennebula_virtual_network.internal.id
  id                 = "1"
}

resource "opennebula_virtual_router_nic" "internal" {
  floating_ip       = true
  virtual_router_id = opennebula_virtual_router.main.id
  network_id        = data.opennebula_virtual_network.internal.id
  model             = "virtio"
  ip                = data.opennebula_virtual_network_address_range.internal.ip4
}
