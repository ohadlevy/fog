module Fog
  module Compute
    class Vsphere
      class Real
        
        # Returns an array of all available datacenters in your cluster.
        #
        def datacenters(return_hash = false)
          @datacenters ||= datacenters_reload
          # Hide the values which are the RbVmomi instances
          if return_hash
            @datacenters
          else
            @datacenters.keys            
          end
        end

        private

        def datacenters_reload
          @rootfolder  ||= @connection.rootFolder
          inventory = @rootfolder.inventory(:Datacenter => [ 'name' ])[@rootfolder]
          # Convert the inventory into a Hash of the form: We remove the
          # property selectors.  { "<dc_name>" => #<RbVmomi::VIM::Datacenter> }
          # The Datacenter instance itself is at index 0 and the properties we
          # collected are at index 1.
          inventory.inject({}) do |memo, (name,dc_ary)|
            memo[name] = dc_ary[0]
            memo
          end
        end
      end

      class Mock
        def datacenters
          [ "Solutions", "Solutions2", "Solutions3" ]
        end
      end
    end
  end
end
