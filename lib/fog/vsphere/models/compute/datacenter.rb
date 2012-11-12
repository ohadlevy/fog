module Fog
  module Compute
    class Vsphere

      class Datacenter < Fog::Model

        identity :id
        attribute :name
        attribute :status

        def clusters
          connection.clusters(:datacenter => name)
        end

        def networks
          connection.networks(:datacenter => name)
        end

        def datastores
          connection.datastores(:datacenter => name)
        end
        
        def vm_folders(path = '')
          connection.folders(:datacenter => name, :type => 'vm', :path => path)
        end

        # Not Implemented
        def network_folders
          connection.folders(:datacenter => name, :type => 'network')
        end

        # Not Implemented
        def datastore_folders
          connection.folders(:datacenter => name, :type => 'datastore')
        end

        def to_s
          name
        end

      end

    end
  end
end
