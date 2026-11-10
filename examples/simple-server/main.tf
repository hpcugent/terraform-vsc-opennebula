# Router definition
module "router" {
  source  = "hpcugent/opennebula/vsc//modules/router"
  version = "0.0.12"
  # VM Which we can ssh to by default
  access_vm = module.SimpleVM.router_access
}
module "SimpleVM" {
  source        = "hpcugent/opennebula/vsc"
  version       = "0.0.12"
  vm_name       = "SimpleExample"
  image_name    = "Rocky Linux 9"
  cpu           = 4
  memory        = 8 #Gib
  rootdisk_size = 30
}
output "services" {
  value = module.router.services_list # Output the port-forwardings of the router
}
