# Infrastructure-as-Code

Iac is a way to manage and provision virtual machines using 
computer-readable files.

## Ansible

![ansible diagram](https://github.com/Benedek4000/eng130_IaC/blob/main/images/ansible.png)

Ansible is an IaC tool, including features for provisioning, configurations 
and deployment.

Ansible default folder: `/etc/ansible/hosts`

### Benefits

- simple
- powerful
- agentless
- uses Python
- playbooks in YAML
- smooth orchestration
- support for integration
- support for operation
- support for test-driven design

### Use cases

- hybrid cloud automation
- network automation
- security automation
- continuous delivery
- provisioning
- configuration management
- 

## Configuration Management

Configuration management is a feature to track and control changes in software.

## Orchestration

Orchestration is managing, coordinating and arranging multiple systems.

## Setting up Ansible with Vagrant

3 Vms:
- controller
- web (192.168.33.10)
- db (192.168.33.11)

### Vagrantfile

code can be found in VM/Vagrantfile

```
# -*- mode: ruby -*-
 # vi: set ft=ruby :

 # All Vagrant configuration is done below. The "2" in Vagrant.configure
 # configures the configuration version (we support older styles for
 # backwards compatibility). Please don't change it unless you know what

 # MULTI SERVER/VMs environment
 #
 Vagrant.configure("2") do |config|
    # creating are Ansible controller
      config.vm.define "controller" do |controller|

       controller.vm.box = "bento/ubuntu-18.04"

       controller.vm.hostname = 'controller'

       controller.vm.synced_folder "./sync_controller", "/home/vagrant/sync"

       controller.vm.provision "shell", path: "provision_controller.sh"

       controller.vm.network :private_network, ip: "192.168.33.12"

       # config.hostsupdater.aliases = ["development.controller"]

      end
    # creating first VM called web
      config.vm.define "web" do |web|

        web.vm.box = "bento/ubuntu-18.04"
       # downloading ubuntu 18.04 image

        web.vm.hostname = 'web'
        # assigning host name to the VM

        web.vm.provision "shell", path: "provision.sh"

        web.vm.network :private_network, ip: "192.168.33.10"
        #   assigning private IP

        #config.hostsupdater.aliases = ["development.web"]
        # creating a link called development.web so we can access web page with this link instread of an IP

      end

    # creating second VM called db
      config.vm.define "db" do |db|

        db.vm.box = "bento/ubuntu-18.04"

        db.vm.hostname = 'db'

        db.vm.network :private_network, ip: "192.168.33.11"

        db.vm.provision "shell", path: "provision.sh"

        #config.hostsupdater.aliases = ["development.db"]
      end


    end
```

### hosts

code can be found in VM/sync_controller/hosts

```
[web]
192.168.33.10 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant

[db]
192.168.33.11 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant
```

### provision_controller.sh

code can be found in VM/provision_controller.sh

the provision performs the following tasks:
- updates and upgrades the controller machine
- installs python dependencies
- installs ansible
- updates `/etc/ansible/hosts`

```
sudo apt update
sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y
sudo rm /etc/ansible/hosts && sudo cp sync/hosts /etc/ansible/hosts
```

### provision.sh

code can be found in VM/provision.sh

the provision performs the following tasks:
- updates and upgrades the controller machine

```
sudo apt update
sudo apt upgrade -y
```

### Create ssh key between agents and master node

- ssh into master node: `vagrant ssh controller`
- go to ansible folder: `cd /etc/ansible`
- ssh into web:
  - `sudo ssh vagrant@192.168.33.10`
  - answer `yes`
  - once in web, exit: `exit`
- ssh into db:
  - `sudo ssh vagrant@192.168.33.11`
  - answer `yes`
  - once in db, exit: `exit`
- test connection: `sudo ansible all -m ping`

### How to copy files from master node to agent node

in master node, use `scp`:  
`scp -r /home/vagrant/[folder or file part] vagrant@[ip of agent node]:[path of target]`

## Inventory

The Ansible inventory contains the information about the hosts and groups 
to be used in a playbook.

## Roles

Ansible roles are used to create reusable automation components, 
like configuration files, templates, tasks and handlers.