module Fog
  module Compute
    class Vsphere
      class Real
        def get_virtual_machine(id, dc = nil)
          convert_vm_mob_ref_to_attr_hash(get_vm_ref(id, dc))
        end

        protected

        def get_vm_ref(id, dc = nil)
          vm = case id
                 # UUID based
                 when /[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/
                   @connection.searchIndex.FindByUuid :uuid => id, :vmSearch => true, :instanceUuid => true, :datacenter => dc
                 else
                   # try to find based on VM name
                   if dc
                     get_datacenter(dc).find_vm(id)
                   else
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
