require 'fog/core/collection'
require 'fog/vsphere/models/compute/folder'

module Fog
  module Compute
    class Vsphere

      class Folders < Fog::Collection

        model Fog::Compute::Vsphere::Folder
        attr_accessor :datacenter

        def get(id)
          requires :datacenter
          new connection.get_folder(id, datacenter)
        end

      end
    end
  end
end
