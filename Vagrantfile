# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  # Kubernetes Master Server
  config.vm.define "master" do |node|
  
    node.vm.box               = "generic/ubuntu2004"
    node.vm.box_check_update  = false
    node.vm.box_version       = "3.3.0"
    node.vm.hostname          = "master.example.com"

    node.vm.network "private_network", ip: "172.17.17.100"
  
    node.vm.provider :virtualbox do |v|
      v.name    = "master"
      v.memory  = 2048
      v.cpus    =  2
    end
  
    node.vm.provider :libvirt do |v|
      v.memory  = 2048
      v.nested  = true
      v.cpus    = 2
    end
  
    node.vm.provision "shell", path: "bootstrap_master.sh"
  
  end


  # Kubernetes Worker Nodes
  NodeCount = 2

  (1..NodeCount).each do |i|

    config.vm.define "worker#{i}" do |node|

      node.vm.box               = "generic/ubuntu2004"
      node.vm.box_check_update  = false
      node.vm.box_version       = "3.3.0"
      node.vm.hostname          = "worker#{i}.example.com"

      node.vm.network "private_network", ip: "172.17.17.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "worker#{i}"
        v.memory  = 2048
        v.cpus    = 2
      end

      node.vm.provider :libvirt do |v|
        v.memory  = 1024
        v.nested  = true
        v.cpus    = 1
      end

      node.vm.provision "shell", path: "bootstrap_worker.sh"

    end

  end

end
