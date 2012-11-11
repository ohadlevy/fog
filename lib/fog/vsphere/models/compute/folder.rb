module Fog
  module Compute
    class Vsphere

      class Folder < Fog::Model

        identity :id

        attribute :name
        attribute :parent
        attribute :datacenter

        def to_s
          name
        end

      end

    end
  end
end
