provider "opennebula" {
  endpoint = "http://localhost:2633/RPC2"
  username = chomp(split(":", file("~/.one/one_auth"))[0])
  password = chomp(split(":", file("~/.one/one_auth"))[1])
}
variables {
  vm_name    = "SimpleExampleTest"
  image_name = "Rocky 9"
  is_windows = false
}
run "mainVM" {

}

run "router" {
  variables {
    access_vm = run.MainVM.router_access
    port_forwards = {
      http = {
        external_port = 80
        ip            = run.webVM.ip
      }
      prometheus = { # Define a port forward rule for the second VM
        external_port = 59999
        internal_port = 9090
        ip            = run.webVM.ip
      }
    }
  }
}

run "webVM" {
  variables {
    start_script      = "dnf install -y nginx prometheus && systemctl enable --now nginx; systemctl enable --now prometheus" # Run install script on creation
    firewall_services = ["http"]                                                                                             # Automatically allows ports 80 & 443
    firewall_rules = [
      {
        protocol = "TCP"
        range    = 9090
      },
    ]
  }
}
