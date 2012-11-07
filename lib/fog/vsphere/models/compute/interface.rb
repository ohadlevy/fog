module Fog
  module Compute
    class Vsphere

      class Interface < Fog::Model
        identity :mac

        attribute :network
        attribute :name
        attribute :status
        attribute :summary
        attribute :type

        def to_s
          name
        end

      end

    end
  end
end
