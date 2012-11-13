module Fog
  module Compute
    class Vsphere

      class Folder < Fog::Model

        identity :id

        attribute :name
        attribute :parent
        attribute :datacenter
        attribute :path

        def list_virtual_machines
          connection.list_virtual_machines(:path => path, :datacenter => datacenter)
        end

        def to_s
          name
        end

      end

    end
  end
end
