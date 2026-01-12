# VSC-OpenNebula
OpenTofu module to deploy opennebula VMs on Tier1 VSC Cloud.

## Usage
For example use cases, check out the [examples](./examples/) directory.

This module is made with **[OpenTofu](https://opentofu.org/)**, a Terraform fork. **Do not** run it with Terraform, since it uses OpenTofu specific features.

### Authenticating
You will need to put your username and token in `~/.one/one_auth`. The module will retrieve the credentials from there.

### Overview
VSC-Opennebula is comprised of the `vsc-opennebula` module itself and the `router` submodule.
Each vsc-cloud project should have **only one router**. That means that if you wish to use this module, you will have to have all of your cloud resources specified in **one opentofu project**.

To start, we recommend creating a new git repo and copying one of the [examples](./examples/) into it. 
Edit the files to your liking.
Then, run `tofu init`.
Finally, run `tofu apply`.

## Development
If you want to test the examples with your working directory, run `./fixup-examples.sh local` This will set the `source` parameter for all the modules to use the local version. Running `./fixup-examples.sh remote` will then do the opposite.

There is a pre-commit hook available that will check if your examples are set to remote mode before comitting. You can install it by running `./pre-commit.sh install`

### Testing
Run the `./run_tests.sh` command to run the tests. This will also temporarily set the examples to `local` mode if they are not, to ensure they are tested against your WIP.

You can also run `tofu test` to just run the module tests on their own.
