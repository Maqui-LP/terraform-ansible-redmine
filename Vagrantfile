# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt install software-properties-common
    apt-add-repository -y -update ppa:ansible/ansible
    apt -y install ansible
    apt install ruby-full -y
  SHELL
  config.vm.network "forwarded_port", guest: 80, host: 8082, host_ip: "127.0.0.1"
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
  end


end
