module Fog
  module Compute
    class Vsphere

      class Cluster < Fog::Model

        identity :id

        attribute :name
        attribute :datacenter
        attribute :num_host
        attribute :num_cpu_cores
        attribute :overall_status

        def resource_pools
          self.attributes[:resource_pools] ||= id.nil? ? [] : Fog::Compute::Vsphere::ResourcePools.new(
            :connection => connection,
            :cluster    => name,
            :datacenter => datacenter
          )
        end

        def to_s
          name
        end

      end

    end
  end
end
