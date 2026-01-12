locals {
  windows_start_script = "net user Admin ${try(random_pet.windows[0].id, "")}"
  base_context = {
    NETWORK        = "YES"
    SET_HOSTNAME   = "${var.vm_name}"
    SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]"
    GROW_ROOTFS    = "YES"
  }
  windows_context = {
    START_SCRIPT = "net user Admin ${try(random_pet.windows[0].id, "")}"
  }
  linux_context = {
    START_SCRIPT = "${var.start_script}"
  }
  final_context = merge(local.base_context, var.custom_context, (var.is_windows ? local.windows_context : local.linux_context))
}

resource "opennebula_virtual_machine" "main" {
  name        = var.vm_name
  description = "VM"
  cpu         = coalesce(var.cpu, data.opennebula_template.template.cpu)
  vcpu        = coalesce(var.vcpu, data.opennebula_template.template.vcpu, 4)
  memory      = try((var.memory * 1024), data.opennebula_template.template.memory)
  cpumodel {
    model = "host-passthrough"
  }
  template_id = data.opennebula_template.template.id
  context     = local.final_context
  os {
    arch = "x86_64"
    boot = "disk0"
  }
  disk {
    image_id = data.opennebula_image.image.id
    size     = local.rootdisk_size
  }
  dynamic "disk" {
    for_each = var.disks
    content {
      size          = disk.value.size * 1024
      volatile_type = "fs"
    }
  }
  on_disk_change = "RECREATE"

  nic {
    network_id      = data.opennebula_virtual_network.main.id
    security_groups = [opennebula_security_group.main.id]
  }
  dynamic "nic" {
    for_each = var.vsc ? [0] : []
    content {
      network_id      = data.opennebula_virtual_network.vsc.id
      security_groups = [opennebula_security_group.main.id]
    }
  }
  dynamic "template_section" {
    for_each = var.is_windows ? [0] : []
    content {
      name = "TOPOLOGY"
      elements = {
        "CORES"   = coalesce(var.vcpu, data.opennebula_template.template.vcpu),
        "SOCKETS" = 1,
        "THREADS" = 1,
      }
    }
  }
}
