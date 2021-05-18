# -*- mode: ruby -*-
# vi: set ft=ruby :

require __dir__ + '/dotenv.rb'

Vagrant.configure("2") do |a|
  a.vagrant.plugins = ['vagrant-vbguest', 'dotenv']

  a.vm.hostname = 'prometheus'

  a.vm.provision "shell", run: "always", inline: 'modprobe vboxsf || true'

  a.vm.synced_folder '.', '/vagrant', type: 'virtualbox'

  a.vm.network :forwarded_port, host: 3000, guest: 3000, host_ip: '127.0.0.1' # pandora
  a.vm.network :forwarded_port, host: 3003, guest: 3003, host_ip: '127.0.0.1' # rack-images
  a.vm.network :forwarded_port, host: 3004, guest: 3004, host_ip: '127.0.0.1' # rack-images (test)
  a.vm.network :forwarded_port, host: 3306, guest: 3306, host_ip: '127.0.0.1' # mariadb
  a.vm.network :forwarded_port, host: 9200, guest: 9200, host_ip: '127.0.0.1' # elasticsearch
  a.vm.network :forwarded_port, host: 9201, guest: 9201, host_ip: '127.0.0.1' # elasticsearch (test)
  a.vm.network :forwarded_port, host: 9222, guest: 9222, host_ip: '127.0.0.1' # headless chrome

  a.vm.provider :virtualbox do |vb|
    vb.name = 'prometheus'
    vb.memory = 4048
    vb.cpus = 2
  end

  vm_name = (
    ENV['PM_VAGRANT_SUFFIX'] && ENV['PM_VAGRANT_SUFFIX'] != '' ?
    "debian.#{ENV['PM_VAGRANT_SUFFIX']}" :
    'debian'
  )

  a.vm.define vm_name, primary: true do |c|
    c.vm.box = 'generic/debian10'
    c.vm.box_version = '1.9.20'

    c.vm.provider :virtualbox do |vb|
      vb.name = "prometheus.#{vm_name}"
    end

    c.vm.provision :shell, path: 'provision.sh', args: 'debian_basics'
    c.vm.provision :shell, path: 'provision.sh', args: 'install_rbenv', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'install_nvm', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'prepare_for_pandora', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'prepare_for_rack_images', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'prepare_for_testing', privileged: false

    # bind-mount node_modules directory in VM
    c.trigger.after :up do |trigger|
      cmds = "
        mkdir -p /home/vagrant/node_modules
        chown vagrant:vagrant /home/vagrant/node_modules
        mkdir -p /vagrant/pandora/node_modules
        chown vagrant:vagrant /vagrant/pandora/node_modules 
        sudo mount --bind /home/vagrant/node_modules /vagrant/pandora/node_modules
      "
      trigger.run_remote = {inline: cmds}
    end

    # copy git user config from host
    c.vm.provision :shell, privileged: false, inline: "
      git config --global user.name #{`git config user.name`}
      git config --global user.email #{`git config user.email`}
    "
  end

  a.vm.define 'centos', autostart: false do |c|
    c.vm.box = 'centos/6'

    c.vm.provider :virtualbox do |vb|
      vb.name = 'prometheus.centos'
    end

    c.vm.provision :shell, path: 'provision.sh', args: 'centos_basics'
    c.vm.provision :shell, path: 'provision.sh', args: 'install_rbenv', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'install_nvm', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'prepare_for_pandora', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'prepare_for_rack_images', privileged: false
    c.vm.provision :shell, path: 'provision.sh', args: 'prepare_for_testing', privileged: false
  end
end
