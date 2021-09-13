# Hyper Homelab
This is a home lab environment based on the following technologies:
- Microsoft Hyper-V
- Oracle VM VirtualBox
- Vagrant
- Ansible

Ansible and Vagrant are always required on the host machine.

Hyper-V and VirtualBox are not fully interchangeable (due to virtual network differences). At least one needs to be installed on the host machine.

## SSH Secrets
Saving secrets outside of source control.
Dependencies:
- `~/.ssh/id_rsa_ansible`
- `~/.ssh/id_rsa_ansible.pub`

Saving the encrypted private key in source control was considered as an option. However, having it in the `~/.ssh` directory makes ssh commands work more easily.

Also, Vagrant auto-generates a key and uses that for the default `vagrant` user. These keys are for the unpriviledged `vince` user.