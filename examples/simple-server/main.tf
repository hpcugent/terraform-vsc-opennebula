# Router definition
module "router" {
  source  = "hpcugent/opennebula/vsc//modules/router"
  version = "0.0.6"
  # VM Which we can ssh to by default
  access_vm = module.SimpleVM.router_access
}
module "SimpleVM" {
  source     = "hpcugent/opennebula/vsc"
  version    = "0.0.6"
  vm_name    = "SimpleExample"
  image_name = "Rocky Linux 9"
  is_windows = false
}
output "services" {
  value = module.router.services_list # Output the port-forwardings of the router
}
