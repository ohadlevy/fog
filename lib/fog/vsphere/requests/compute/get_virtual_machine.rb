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
            if id =~ /[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/
              vm = @connection.searchIndex.FindByUuid :uuid => id, :vmSearch => true, :instanceUuid => true, :datacenter => datacenter_name
            else
              # The required path syntax - 
              # 'topfolder/subfolder/anotherfolder/vmname'
              # split the path up into array, pop off the vm name
              # join back to string path for folder find.
              path_ary = id.split('/')
              vm_name = path_ary.pop
              path = path_ary.join('/')
              # try to find based on VM name if datacenter is set
              folder = get_raw_folder(path, datacenter_name)
              vm = folder.find(vm_name, RbVmomi::VIM::VirtualMachine)
              raise Fog::Compute::Vsphere::NotFound, "#{id} was not found or returned as a folder" unless vm
            end
          else
            # Works but assumes all names are unique, could return multiple
            # results from different Datacenters. Also id should be relative
            # datacenter path (eg: 'Templates/VMName Here')
            vm = raw_datacenters.map { |d| d.find_vm(id) }.compact.first
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