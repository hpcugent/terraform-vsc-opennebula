data "opennebula_user" "me" {
  name = chomp(split(":", file("~/.one/one_auth"))[0])
}
data "opennebula_group" "primary" {
  id = data.opennebula_user.me.primary_group
}

locals {
  router-name = "${data.opennebula_group.primary.name}_router"
  base_context = {
    NETWORK        = "YES"
    HOSTNAME       = "${local.router-name}"
    SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]"
    START_SCRIPT   = "${var.start_script}"
  }
  network_context = {
    # Turn off features we don't use
    ONEAPP_VNF_SDNAT4_ONEGATE_ENABLED = "NO"
    ONEAPP_VNF_DHCP4_ENABLED          = "NO",
    ONEAPP_VNF_DNS_ENABLED            = "NO",
    ONEAPP_VNF_HAPROXY_ENABLED        = "NO",
    ONEAPP_VNF_LB_ENABLED             = "NO",
    # NAT
    ONEAPP_VNF_NAT4_ENABLED        = "YES"
    ONEAPP_VNF_NAT4_INTERFACES_OUT = "eth0"
    ONEAPP_VNF_ROUTER4_INTERFACES  = "eth0 eth1"
  }
  final_context = merge(local.base_context, local.network_context, local.port_forward_context)
}

data "opennebula_template" "base" {
  name = "vr1"
}

resource "opennebula_virtual_router" "main" {
  name                 = local.router-name
  instance_template_id = data.opennebula_template.base.id
}
data "opennebula_image" "image" {
  name = "vr1"
}
# Resource to help trigger a replace
resource "terraform_data" "port-forwards" {
  input = local.port_forward_context
}
resource "opennebula_virtual_router_instance" "main" {
  count             = 2
  name              = "${local.router-name}-instance-${count.index}"
  virtual_router_id = opennebula_virtual_router.main.id
  context           = local.final_context
  os {
    arch = "x86_64"
    boot = "disk0"
  }
  disk {
    image_id = data.opennebula_image.image.id
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [terraform_data.port-forwards]
  }
}

data "opennebula_virtual_network" "external" {
  name = "altaria.vip"
}

data "opennebula_virtual_network" "internal" {
  name = "altaria.test"
}

resource "opennebula_virtual_router_nic" "external" {
  floating_ip       = true
  floating_only     = true
  virtual_router_id = opennebula_virtual_router.main.id
  network_id        = data.opennebula_virtual_network.external.id
  depends_on        = [opennebula_virtual_router_instance.main]
  model             = "virtio"
}

resource "opennebula_virtual_router_nic" "internal" {
  floating_ip       = true
  virtual_router_id = opennebula_virtual_router.main.id
  network_id        = data.opennebula_virtual_network.internal.id
  depends_on        = [opennebula_virtual_router_nic.external]
  model             = "virtio"
}
