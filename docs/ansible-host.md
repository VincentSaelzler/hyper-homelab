# Ansible Host
Everything that needs to be done to have development environment that runs the Ansible playbooks.

# Programs
- Visual Studio Code
- Ansible

# Secrets (TODO - document more)
Secrets like the `root` password are all encrypted using `ansible vault`.

The password for that needs to be saved in the user that's running Ansible's home directory.
```sh
echo 'u3pV6qM3UKDwkGrUq9qjkv3XDNwKu2hQ' > ~/.ansible/vault_pw.txt
```

- ssh keys

# Personalization
This will make life much easier.
```sh
echo 'alias ans="ansible-playbook -i inventory/hosts.yml --vault-password-file ~/.ansible/vault_pw.txt"' >> ~/.bashrc
source ~/.bashrc
```

# Running
Change directories to `ansible` (within this project folder) before running. Ansible is particular about where files are located in relation to each other, and what the current directory is.

The only other parameter that's normally required is the playbook.

Using the alias, running a test (`ping.yml`) playbook looks like this:
```sh
~/src/hyper-homelab/ansible$ ans ping.yml
```