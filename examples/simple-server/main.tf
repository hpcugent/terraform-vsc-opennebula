# Router definition
module "router" {
  source  = "hpcugent/vsc/opennebula//submodules/router"
  version = "0.0.1"
  # VM Which we can ssh to by default
  access_vm = module.SimpleVM.router_access
}
module "SimpleVM" {
  source     = "hpcugent/vsc/opennebula"
  version    = "0.0.1"
  vm_name    = "SimpleExample"
  image_name = "Rocky 9"
  is_windows = false
}
output "services" {
  value = module.router.services_list # Output the port-forwardings of the router
}
