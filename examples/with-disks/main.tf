# Router definition
module "router" {
  source  = "hpcugent/opennebula/vsc//modules/router"
  version = "0.0.12"
  # VM Which we can ssh to by default
  access_vm = module.ExampleWithDisks.router_access
}
module "ExampleWithDisks" {
  source        = "hpcugent/opennebula/vsc"
  version       = "0.0.12"
  vm_name       = "ExampleWithDisks"
  image_name    = "Rocky Linux 9"
  cpu           = 4
  memory        = 8 #Gib
  rootdisk_size = 30
  disks = {
    "DataDisk" = {
      size = 30 # Initial size. Increases need to be done manually.
    }
    "ImageDisk" = {
      image_id = 10 # Disk will have the same size as the image until manually increased.
    }
  }
}
output "services" {
  value = module.router.services_list # Output the port-forwardings of the router
}
