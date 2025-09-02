# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

Vagrant.configure('2') do |config|
  # Ensure the 'vagrant-libvirt' plugin is installed:
  config.vagrant.plugins = 'vagrant-libvirt'

  # indicate the preferred provider
  config.vm.provider 'libvirt'

  # guest resource allocation
  config.vm.provider 'libvirt' do |libvirt|
    libvirt.cpus = 2
    libvirt.numa_nodes = [{ cpus: '0-1', memory: 4096, memAccess: 'shared' }]
    libvirt.memorybacking :access, mode: 'shared'

    # make the ST-LINK acessible to the guest:
    # [https://vagrant-libvirt.github.io/vagrant-libvirt/configuration.html#usb-device-passthrough]
    #
    # (host) lsusb | grep ST-LINK
    # Bus 001 Device 112: ID 0483:3748 STMicroelectronics ST-LINK/V2
    libvirt.usb vendor: '0x0483', product: '0x3748', startupPolicy: 'optional'
    libvirt.pci domain: '0x0000', bus: '0x00', slot: '0x14', function: '0x0'
    libvirt.kvm_hidden = true
    # REFERENCES:
    # - https://forum.manjaro.org/t/no-usb-connection-on-vm-libvirt-virt-manager/167691/8
    # - https://vagrant-libvirt.github.io/vagrant-libvirt/configuration.html#usb-device-passthrough
    #
  end

  # prefer a user-defined synced folder
  # (https://vagrant-libvirt.github.io/vagrant-libvirt/examples.html#synced-folders)
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/home/vagrant/share', type: 'virtiofs'

  # using a debian bookworm guest
  config.vm.box = 'generic/debian12'

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = './playbook.yml'
  end
end
