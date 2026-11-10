# Public router definition
# Same definition as in other examples
module "router" {
  source    = "hpcugent/opennebula/vsc//modules/router"
  version   = "0.0.12"
  access_vm = module.SimpleVSCVM.router_access
}
output "publicServices" {
  value = module.router.services_list # Output the port-forwardings of the public router
}
# VSC Router definition
module "VSCrouter" {
  source    = "hpcugent/opennebula/vsc//modules/router"
  version   = "0.0.12"
  vsc       = true                             # Connect to VSC Public net and VSC Internal net
  access_vm = module.SimpleVSCVM.router_access # Optional, adds SSH forwarding automatically.
}
output "VSCServices" {
  value = module.VSCrouter.services_list # Output the port-forwardings of the VSC router
}
module "SimpleVSCVM" {
  source        = "hpcugent/opennebula/vsc"
  version       = "0.0.12"
  vm_name       = "SimpleVSCExample"
  image_name    = "Rocky Linux 9"
  cpu           = 4
  memory        = 8 #Gib
  rootdisk_size = 30
  vsc           = true # Connect to VSC Internal net
}

