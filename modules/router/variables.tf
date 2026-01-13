variable "start_script" {
  type    = string
  default = <<EOF
#!/bin/bash
iptables -t nat -A POSTROUTING -j MASQUERADE
sysctl -w net.ipv4.ip_forward=1
EOF
}
