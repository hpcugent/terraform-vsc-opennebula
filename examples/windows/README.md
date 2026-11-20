# Windows example
This example will create a Windows VM.

## Access
Opentofu will output:
```
password = <sensitive>
services = {
  "Primary VM" = "ssh Admin@193.190.80.90"
}
```
You can connect to the vm through SSH, or use an RDP client that supports SSH tunnelling.
See [VSC Cloud Docs](https://docs.vscentrum.be/cloud/pilot/accessing_vms.html#windows) for more information.

## Password
**The password is saved in the statefile, so don't commit it to a git repository!**
You can show the windows password in `tofu output` by adding `--show-sensitive`.
