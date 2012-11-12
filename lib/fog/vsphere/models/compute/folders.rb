require 'fog/core/collection'
require 'fog/vsphere/models/compute/folder'

module Fog
  module Compute
    class Vsphere

      class Folders < Fog::Collection

        model Fog::Compute::Vsphere::Folder
        attr_accessor :datacenter
        attr_accessor :path
        attr_accessor :type

        def all(filters = {})
          load connection.list_folders(filters.merge(:datacenter => datacenter, :path => path))
        end

        def get(id, filters = {})
          new connection.get_folder(id, filters.merge(:datacenter => datacenter, :type => type))
        end

      end
    end
  end
end
