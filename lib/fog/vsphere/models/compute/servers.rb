require 'fog/core/collection'
require 'fog/vsphere/models/compute/server'

module Fog
  module Compute
    class Vsphere

      class Servers < Fog::Collection

        model Fog::Compute::Vsphere::Server

        # 'path' => '/Datacenters/vm/Jeff/Templates' will be MUCH faster.
        # than simply listing everything.
        def all(filters = {})
          # REVISIT: I'm not sure if this is the best way to implement search
          # filters on a collection but it does work.  I need to study the AWS
          # code more to make sure this matches up.
          filters['folder'] ||= attributes['folder']
          response = connection.list_virtual_machines(filters)
          load(response['virtual_machines'])
        end

        def get(id)
          new connection.get_virtual_machine id
        rescue Fog::Compute::Vsphere::NotFound
          nil
        end

      end

    end
  end
end
