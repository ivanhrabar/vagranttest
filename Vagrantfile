# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # Prepared for multiple machines, for now we only have one.
    config.vm.define "leaseonline" do |leaseonline|
        # Box settings
        leaseonline.vm.box = "bento/ubuntu-16.04"
        #leaseonline.vm.box_url = "http://files.vagrantup.com/precise32.box"

        # VirtualBox name
        leaseonline.vm.provider "virtualbox" do |v|
            v.name = "leaseonline"
        end

        # Network settings
        #leaseonline.vm.network "private_network", ip: "192.168.50.7"
        leaseonline.vm.network :forwarded_port, guest: 80, host:8007
        leaseonline.vm.network :forwarded_port, guest: 3306, host:3307

        # Vagrant v1.1+
        config.vm.synced_folder "./", "/var/www", 
	#    id: "vagrant-root",
            owner: "vagrant",
            group: "www-data",
            mount_options: ["dmode=775,fmode=664"]

        # Provisioning
        leaseonline.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
        leaseonline.vm.provision :shell, :path => "vagrant.sh"
    end

end
