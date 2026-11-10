locals {
  windows_start_script = "net user Admin ${try(random_pet.windows.id, "")}"
  base_context = {
    NETWORK        = "YES"
    SET_HOSTNAME   = "${var.vm_name}"
    SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]"
    GROW_ROOTFS    = "YES"
  }
  vsc_context = {
    FILES_DS     = "$FILE[IMAGE_ID=${data.opennebula_image.vsc_routes.id}]"
    INIT_SCRIPTS = "vsc_vm_routes.sh"
  }
  windows_context = {
    START_SCRIPT = "net user Admin ${try(random_pet.windows.id, "")}; sc.exe config sshd start= auto; net start sshd"
  }
  linux_context = {
    START_SCRIPT = "${var.start_script}"
  }
  final_context = merge(local.base_context, var.custom_context, (var.is_windows ? local.windows_context : local.linux_context), ((!var.is_windows && var.vsc) ? local.vsc_context : null))
}
module "rootdisk" {
  source     = "./modules/disk"
  disk_type  = "image"
  image_name = var.image_name
  name       = "${var.vm_name}_root_${substr(md5(var.image_name), 0, 6)}"
  persistent = true
}
module "disks" {
  for_each   = var.disks
  source     = "./modules/disk"
  disk_type  = each.value.image_id == null ? "disk" : "image"
  image_id   = each.value.image_id
  size       = try(each.value.size * 1024, null)
  name       = each.key
  persistent = true
}
data "opennebula_image" "vsc_routes" {
  name = "vsc_vm_routes.sh"
}

resource "opennebula_virtual_machine" "main" {
  name        = var.vm_name
  description = "VM"
  cpu         = coalesce(var.cpu, data.opennebula_template.template.cpu)
  vcpu        = coalesce(var.cpu, data.opennebula_template.template.cpu)
  memory      = try((var.memory * 1024), data.opennebula_template.template.memory)
  template_id = data.opennebula_template.template.id
  context     = local.final_context
  os {
    arch    = "x86_64"
    boot    = "disk0"
    machine = "q35"
  }
  disk {
    image_id = module.rootdisk.disk_id
  }
  dynamic "disk" {
    for_each = module.disks
    content {
      image_id = disk.value.disk_id
    }
  }
  nic {
    network_id = data.opennebula_virtual_network.main.id
  }
  dynamic "nic" {
    for_each = var.vsc ? [0] : []
    content {
      network_id = data.opennebula_virtual_network.vsc.id
    }
  }
  dynamic "template_section" {
    for_each = var.is_windows ? [0] : []
    content {
      name = "TOPOLOGY"
      elements = {
        "CORES"         = max(coalesce(var.cpu / 2, data.opennebula_template.template.cpu / 2), 1),
        "SOCKETS"       = 1,
        "THREADS"       = 2,
        "HUGEPAGE_SIZE" = 1024, # Since this is in the base template, removing it is not allowed.
      }
    }
  }
  lifecycle {
    postcondition {
      condition     = self.memory <= local.MAX_MEMORY
      error_message = "Memory may not exceed ${local.MAX_MEMORY} Mib."
    }
    postcondition {
      condition     = self.cpu <= local.MAX_CPU
      error_message = "CPU may not exceed ${local.MAX_CPU}."
    }
    ignore_changes       = [disk, template_section]
    replace_triggered_by = [terraform_data.image]
  }
}
resource "terraform_data" "image" {
  input = var.image_name
}
