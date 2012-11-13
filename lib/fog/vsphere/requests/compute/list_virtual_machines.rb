module Fog
  module Compute
    class Vsphere
      class Real
        def list_virtual_machines(options = {})
          # Listing all VM's can be quite slow and expensive.  Try and optimize
          # based on the available options we have.  These conditions are in
          # ascending order of  time to complete for large deployments.
          if options['instance_uuid'] then
            [connection.get_virtual_machine(options['instance_uuid'])]
          elsif options[:path] && options[:datacenter] then
            list_all_virtual_machines_in_folder(options[:path], options[:datacenter])
          else
            list_all_virtual_machines(options)
          end
        end

        private

        def list_all_virtual_machines_in_folder(path, datacenter_name)
          # backwards compatibility
          folder = get_raw_vmfolder(path, datacenter_name)

          # This should be efficient since we're not obtaining properties
          virtual_machines = folder.children.inject([]) do |ary, child|
            if child.is_a? RbVmomi::VIM::VirtualMachine then
              ary << convert_vm_mob_ref_to_attr_hash(child)
            end
            ary
          end

          # Return the managed objects themselves as an array.  These may be converted
          # to an attribute has using convert_vm_mob_ref_to_attr_hash
          virtual_machines
        end

        def list_all_virtual_machines(options = { })
          datacenters = find_datacenters(options[:datacenter])
          # TODO: go though nested folders
          vms         = datacenters.map { |dc| dc.vmFolder.childEntity.grep(RbVmomi::VIM::VirtualMachine) }.flatten
          # remove all template based virtual machines
          vms.delete_if { |v| v.config.template }

          vms.map do |vm_mob|
            convert_vm_mob_ref_to_attr_hash(vm_mob)
          end
        end

        def get_folder_path(folder, root = nil)
          if ( not folder.methods.include?('parent') ) or ( folder == root )
            return
          end
          "#{get_folder_path(folder.parent)}/#{folder.name}"
        end
      end

      class Mock

        def get_folder_path(folder, root = nil)
          nil
        end

        def list_virtual_machines(options = {})
          case options['instance_uuid']
          when nil
            rval = YAML.load <<-'ENDvmLISTING'
---
virtual_machines:
- name: centos56gm
  hypervisor: gunab.puppetlabs.lan
  tools_version: guestToolsCurrent
  ipaddress:
  mo_ref: vm-698
  power_state: poweredOff
  uuid: 42322347-d791-cd34-80b9-e25fe28ad37c
  is_a_template: true
  id: 50323f93-6835-1178-8b8f-9e2109890e1a
  tools_state: toolsNotRunning
  connection_state: connected
  instance_uuid: 50323f93-6835-1178-8b8f-9e2109890e1a
  hostname:
  mac_addresses:
    Network adapter 1: 00:50:56:b2:00:a1
  operatingsystem:
- name: centos56gm2
  hypervisor: gunab.puppetlabs.lan
  tools_version: guestToolsCurrent
  ipaddress:
  mo_ref: vm-640
  power_state: poweredOff
  uuid: 564ddcbe-853a-d29a-b329-a0a3693a004d
  is_a_template: true
  id: 5257dee8-050c-cbcd-ae25-db0e582ab530
  tools_state: toolsNotRunning
  connection_state: connected
  instance_uuid: 5257dee8-050c-cbcd-ae25-db0e582ab530
  hostname:
  mac_addresses:
    Network adapter 1: 00:0c:29:3a:00:4d
  operatingsystem:
- name: dashboard_gm
  hypervisor: gunab.puppetlabs.lan
  tools_version: guestToolsCurrent
  ipaddress: 192.168.100.184
  mo_ref: vm-669
  power_state: poweredOn
  uuid: 564d3f91-3452-a509-a678-1246f7897979
  is_a_template: false
  id: 5032739c-c871-c0d2-034f-9700a0b5383e
  tools_state: toolsOk
  connection_state: connected
  instance_uuid: 5032739c-c871-c0d2-034f-9700a0b5383e
  hostname: compliance.puppetlabs.vm
  mac_addresses:
    Network adapter 1: 00:50:56:b2:00:96
  operatingsystem: Red Hat Enterprise Linux 6 (64-bit)
- name: jefftest
  hypervisor: gunab.puppetlabs.lan
  tools_version: guestToolsCurrent
  ipaddress: 192.168.100.187
  mo_ref: vm-715
  power_state: poweredOn
  uuid: 42329da7-e8ab-29ec-1892-d6a4a964912a
  is_a_template: false
  id: 5032c8a5-9c5e-ba7a-3804-832a03e16381
  tools_state: toolsOk
  connection_state: connected
  instance_uuid: 5032c8a5-9c5e-ba7a-3804-832a03e16381
  hostname: centos56gm.localdomain
  mac_addresses:
    Network adapter 1: 00:50:56:b2:00:af
  operatingsystem: CentOS 4/5 (32-bit)
ENDvmLISTING
          when '5032c8a5-9c5e-ba7a-3804-832a03e16381'
            YAML.load <<-'5032c8a5-9c5e-ba7a-3804-832a03e16381'
---
virtual_machines:
- name: jefftest
  hypervisor: gunab.puppetlabs.lan
  tools_version: guestToolsCurrent
  ipaddress: 192.168.100.187
  mo_ref: vm-715
  power_state: poweredOn
  uuid: 42329da7-e8ab-29ec-1892-d6a4a964912a
  is_a_template: false
  id: 5032c8a5-9c5e-ba7a-3804-832a03e16381
  tools_state: toolsOk
  connection_state: connected
  instance_uuid: 5032c8a5-9c5e-ba7a-3804-832a03e16381
  hostname: centos56gm.localdomain
  mac_addresses:
    Network adapter 1: 00:50:56:b2:00:af
  operatingsystem: CentOS 4/5 (32-bit)
            5032c8a5-9c5e-ba7a-3804-832a03e16381
          when 'does-not-exist-and-is-not-a-uuid', '50323f93-6835-1178-8b8f-9e2109890e1a'
            { 'virtual_machines' => [] }
          end
        end
      end
    end
  end
end
