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

        def to_s
          name
        end

      end

    end
  end
end
