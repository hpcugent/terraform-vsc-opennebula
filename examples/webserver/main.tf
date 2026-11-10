# Router definition
module "router" {
  source  = "hpcugent/opennebula/vsc//modules/router"
  version = "0.0.12"
  #VM Which we can ssh to by default
  access_vm = module.WebServer.router_access
  port_forwards = {
    "http" = {
      external_port = 80 # Add port 80
    }
    "https" = {
      external_port = 443 # add port 443
    }
  }
}
module "WebServer" {
  source        = "hpcugent/opennebula/vsc"
  version       = "0.0.12"
  vm_name       = "WebExample"
  image_name    = "Rocky Linux 9"
  start_script  = "dnf install -y nginx && systemctl enable --now nginx" # Run install script on creation
  cpu           = 2
  memory        = 4 #Gib
  rootdisk_size = 30
}
output "services" {
  value = module.router.services_list # Output the port-forwardings of the router
}
