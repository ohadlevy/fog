require 'fog/core/collection'
require 'fog/vsphere/models/compute/folder'

module Fog
  module Compute
    class Vsphere

      class Folders < Fog::Collection

        model Fog::Compute::Vsphere::Folder
        attr_accessor :datacenter

        def all(filters = {})
          load connection.list_vmfolders(filters)
        end

        def get(id, filters = {})
          requires :datacenter
          filters.merge!(:datacenter => filters[:datacenter])
          type = filters[:type]
          type ||= 'vm'
          case type
          when 'vm'
            new connection.get_vmfolder(id, filters)
          when 'network'
            # augment me!
          when 'datastore'
            #add moar
          else
            raise ArgumentError, "#{type} is unknown"
          end
        end

      end
    end
  end
end
