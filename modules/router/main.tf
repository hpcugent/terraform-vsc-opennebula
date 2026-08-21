data "opennebula_user" "me" {
  name = chomp(split(":", file("~/.one/one_auth"))[0])
}
variable "use_demo_format" {
  type = bool
  default = false
  description = "Use VSC demo project format. Only change for dev purposes."
}
locals {
  group = data.opennebula_group.primary.name
}
data "opennebula_group" "primary" {
  name = var.group != "" ? var.group : null
  id   = var.group == "" ? data.opennebula_user.me.primary_group : null
}

locals {
  router-name = "${data.opennebula_group.primary.name}_${var.vsc ? "router_vsc" : "router"}"
  base_context = {
    NETWORK        = "YES"
    SET_HOSTNAME   = "${local.router-name}"
    SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]"
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
  name = var.vsc ? "vr_vsc" : "vr"
}

resource "opennebula_virtual_router" "main" {
  name                 = local.router-name
  instance_template_id = data.opennebula_template.base.id
}
data "opennebula_image" "image" {
  name = "vr"
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
