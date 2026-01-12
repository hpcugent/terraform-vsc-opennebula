terraform {
  required_providers {
    opennebula = {
      source  = "OpenNebula/opennebula"
      version = "~> 1.5.0"
    }
  }
}
provider "opennebula" {
  endpoint = "http://localhost:2633/RPC2"
  username = chomp(split(":", file("~/.one/one_auth"))[0])
  password = chomp(split(":", file("~/.one/one_auth"))[1])
}
