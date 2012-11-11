module Fog
  module Compute
    class Vsphere
      class Real
        def get_virtual_machine(id, datacenter_name = nil)
          convert_vm_mob_ref_to_attr_hash(get_vm_ref(id, datacenter_name))
        end

        protected

        def get_vm_ref(id, datacenter_name = nil)
          # The required id syntax - 'topfolder/subfolder/anotherfolder'
          # or uuid
          if datacenter_name
            # The required path syntax - 'topfolder/subfolder/anotherfolder'
            path_ary = id.split('/')
            vm_name = path_ary.pop
            dc = get_raw_datacenter(datacenter_name)
            dc_root_folder = dc.vmFolder
            # try to find based on VM name if datacenter is set
            # Walk the tree resetting the folder pointer as we go
            folder = get_raw_folder(path_ary.join('/'), datacenter_name)
            vm = folder.find(vm_name, RbVmomi::VIM::VirtualMachine)
            raise Fog::Compute::Vsphere::NotFound, "#{id} was not found or returned as a folder" unless vm
          else
            vm = case id
              # UUID based search (needs test)
              when /[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/
                @connection.searchIndex.FindByUuid :uuid => id, :vmSearch => true, :instanceUuid => true, :datacenter => datacenter_name
              else
                # Don't believe this works needs test
                raw_datacenters.map { |d| d.find_vm(id) }.compact.first
            end
          end
          vm ? vm : raise(Fog::Compute::Vsphere::NotFound, "#{id} was not found")
        end
      end

      class Mock
        def get_virtual_machine(id, dc = nil)
        end
      end
    end
  end
end