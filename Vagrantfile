# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.provision "shell", inline: <<-SHELL
    apt update
    apt-get -y install python3-pip
    python3 -m pip install ansible
    apt install ruby-full -y
  SHELL
  config.vm.network "forwarded_port", guest: 80, host: 8082, host_ip: "127.0.0.1"
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/playbook.yml"
  end


end
