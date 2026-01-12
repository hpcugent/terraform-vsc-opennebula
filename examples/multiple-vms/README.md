# Webserver example
This example illustrates how to run multiple VMs with vsc-opennebula

## Example setup
This example will set up 2 VMs. One (Primary) will be "public", the other one (Secondary) will be "private".
The virtual router will forward traffic from port 51001 to port 80 on Secondary.
Primary will have port forwardings for ports 80 and 22 (automatic, because it is the access_vm).

## Accessing the private VM(s)
You can access the private VM(s) by using the router's IP as a jumphost. The output of this project shows you an example of this.
