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

       controller.vm.synced_folder "./sync_controller_controller", "/home/vagrant/sync_controller"

       controller.vm.synced_folder "./sync_controller_web", "/home/vagrant/sync_web"

       controller.vm.synced_folder "./sync_controller_db", "/home/vagrant/sync_db"

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

        web.vm.provision "shell", path: "provision_web.sh"

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

        db.vm.provision "shell", path: "provision_db.sh"

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

```commandline
sudo apt update
sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y
sudo apt install sshpass -y
sudo apt install tree -y
sudo rm /etc/ansible/hosts && sudo cp sync/hosts /etc/ansible/hosts
```

### provision.sh

code can be found in VM/provision_web.sh and in VM/provision_db.sh

the provision performs the following tasks:
- updates and upgrades the web and db machines

```commandline
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

## Launching an EC2 instance from vagrant

add aws access key and secret key:
- `cd /etc/ansible`
- `mkdir group_vars/all`
- `cd group_vars/all`
- `sudo ansible-vault create pass.yml`
- insert:
  - `aws_access_key: [enter aws access key]`
  - `aws_secret_key: [enter aws secret key]`

create_ec2.yml:
- creates security group
- creates instance

```yaml
---

- hosts: localhost
  connection: local
  gather_facts: False

  vars:
    key_name: eng130_benedek_aws
    region: eu-west-1
    image: ami-0a68e18ba7ccba285 # ami-0f93b5fd8f220e428 # https://cloud-images.ubuntu.com/locator/ec2/
    id: "eng130-benedek-ansible-web"
    sec_group: "{{ id }}-sec"

  tasks:

    - name: Facts
      block:

      - name: Get instances facts
        ec2_instance_facts:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          region: "{{ region }}"
        register: result

      - name: Instances ID
        debug:
          msg: "ID: {{ item.instance_id }} - State: {{ item.state.name }} - Public DNS: {{ item.public_dns_name }}"
        loop: "{{ result.instances }}"

      tags: always


    - name: Provisioning EC2 instances
      block:

      - name: Upload public key to AWS
        ec2_key:
          name: "{{ key_name }}"
          key_material: "{{ lookup('file', '~/.ssh/{{ key_name }}.pub') }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"

      - name: Create security group
        ec2_group:
          name: "{{ sec_group }}"
          description: "Sec group for app {{ id }}"
          # vpc_id: 12345
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          rules:
            - proto: tcp
              ports:
                - 22
              cidr_ip: 0.0.0.0/0
              rule_desc: allow all on ssh port
            - proto: tcp
              ports:
                - 80
              cidr_ip: 0.0.0.0/0
              rule_desc: allow http access 
        register: result_sec_group

      - name: Provision instance(s)
        ec2:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          key_name: "{{ key_name }}"
          id: "{{ id }}"
          group_id: "{{ result_sec_group.group_id }}"
          image: "{{ image }}"
          instance_type: t2.micro
          region: "{{ region }}"
          wait: true
          count: 1

      tags: ['never', 'create_ec2']
```

launch using: `sudo ansible-playbook create_ec2.yml --ask-vault-pass --tags create_ec2`

## create launcher to set up controller-web-db on aws

files are in the VM/AWS folder  
!!!not tested!!!

## Infrastructure-as-Code - Orchestration with Terraform

### Terraform

Terraform is an infrastructure as code tool owned by HashiCorp. Users can create and define
data centre infrastructure using either the HashiCorp Configuration Language
or JSON.

![terraform diagram](https://github.com/Benedek4000/eng130_IaC/blob/main/images/terraform.png)

#### Use cases

- build environments
- connect multiple clouds
- application deployment, monitoring and scaling
- policy compliance and management
- PaaS
- support for Kubernetes

#### Who is using it

- mostly DevOps teams

#### Benefits

- open-source
- cross-cloud


