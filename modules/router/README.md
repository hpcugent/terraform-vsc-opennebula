# VSC Opennebula Router
vsc-opennebula submodule that creates a Virtual Router and provides an easy way to configure port forwarding.

## Example

```hcl
module "router" {
  source  = "hpcugent/opennebula/vsc//modules/router"
  version = "0.0.6"
  # VM Which we can ssh to by default
  access_vm = module.SimpleVM.router_access
  port_forwards = {
    "http" = {
      external_port = 80 # Add port 80 for the access VM
    }
  }
}

module "SimpleVM" {
  source     = "hpcugent/opennebula/vsc"
  version    = "0.0.6"
  vm_name    = "SimpleExample"
  image_name = "Rocky Linux 9"
  is_windows = false
}
```