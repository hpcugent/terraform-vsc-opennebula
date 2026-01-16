# Router definition
module "router" {
  source  = "hpcugent/opennebula/vsc//modules/router"
  version = "0.0.3"
  #VM Which we can ssh to by default
  access_vm = module.Main.router_access
  port_forwards = {
    "http" = {
      external_port = 80 # Add port 80 for the main VM
    }
    "http_secondary" = { # Define a port forward rule for the second VM
      external_port = 51001
      internal_port = 80
      ip            = module.Secondary.ip
    }
  }
}
module "Main" {
  source            = "hpcugent/opennebula/vsc"
  version           = "0.0.3"
  vm_name           = "MultipleExampleMain"
  image_name        = "Rocky 9"
  start_script      = "dnf install -y nginx && systemctl enable --now nginx" # Run install script on creation
  is_windows        = false
  firewall_services = ["http"] # Automatically allows ports 80 & 443
}
module "Secondary" {
  source            = "hpcugent/opennebula/vsc"
  version           = "0.0.3"
  vm_name           = "MultipleExampleSecondary"
  image_name        = "Ubuntu 24.04"
  start_script      = "apt install -y nginx && systemctl enable --now nginx" # Run install script on creation
  is_windows        = false
  firewall_services = ["http"] # Automatically allows ports 80 & 443
}
output "services" {
  value = module.router.services_list # Output the port-forwardings of the router
}
output "secondary" {
  value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J snorlax,root@${module.router.router-ip} root@${module.Secondary.ip}"
}
