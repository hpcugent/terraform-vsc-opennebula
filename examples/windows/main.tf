# Router definition
module "router" {
  source  = "hpcugent/opennebula/vsc//modules/router"
  version = "0.0.3"
  #VM Which we can ssh/rdp to by default
  access_vm = module.vsc-opennebula.router_access
}
module "vsc-opennebula" {
  source        = "hpcugent/opennebula/vsc"
  version       = "0.0.3"
  vm_name       = "JonTest"
  image_name    = "Windows 11"
  rootdisk_size = 100 # Give Windows some more space
  memory        = 6
  cpu           = 8
  vcpu          = 8
  is_windows    = true
}
output "services" {
  value = module.router.services_list # Output the port-forwardings of the router
}
