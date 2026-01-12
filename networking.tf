data "opennebula_virtual_network" "main" {
  name = "altaria.test"
}
data "opennebula_virtual_network" "vsc" {
  name = "altaria.vsc"
}
resource "opennebula_security_group" "main" {
  name        = "${var.vm_name}-security-group"
  description = "Terraform security group"

  rule {
    protocol  = "ALL"
    rule_type = "OUTBOUND"
  }

  rule {
    protocol  = "TCP"
    rule_type = "INBOUND"
    range     = "22"
  }

  rule {
    protocol  = "ICMP"
    rule_type = "INBOUND"
  }
  dynamic "rule" {
    for_each = var.firewall_rules
    content {
      rule_type = rule.value.rule_type
      range     = rule.value.range
      protocol  = rule.value.protocol
    }
  }
  dynamic "rule" {
    for_each = {
      for name in var.firewall_services :
      name => local.service-templates[name]
      if contains(keys(local.service-templates), name)
    }

    content {
      protocol   = rule.value.protocol
      range      = try(rule.value.range, null)
      rule_type  = try(rule.value.rule_type, "INBOUND")
      network_id = try(rule.value.network_id, null)
    }
  }
}
locals {
  service-templates = {
    ssh = {
      range    = 22
      protocol = "TCP"
    }
    http = {
      range    = "80,443"
      protocol = "TCP"
    }
    rdp = {
      range    = 3389
      protocol = "TCP"
    }
    nfs = {
      range    = 2049
      protocol = "TCP"
    }
    smb = {
      range    = 445
      protocol = "TCP"
    }
    all-local = {
      rule_type  = "INBOUND"
      protocol   = "ALL"
      network_id = data.opennebula_virtual_network.main.id
    }
  }
}
