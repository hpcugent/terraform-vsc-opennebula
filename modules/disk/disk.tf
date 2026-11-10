data "opennebula_image" "image" {
  id   = var.image_id
  name = var.image_name
  lifecycle {
    enabled = (var.image_id != null || var.image_name != null)
  }
}



resource "opennebula_image" "image" {
  clone_from_image = try(data.opennebula_image.image.id, null)
  name             = var.name
  permissions      = "660" #USER and GROUP use & manage
  size             = var.size
  type             = var.disk_type == "disk" ? "DATABLOCK" : null
  datastore_id     = 100
  persistent       = var.persistent
  lifecycle {
    ignore_changes = [size] # For some reason this forces a recreate
  }
}
