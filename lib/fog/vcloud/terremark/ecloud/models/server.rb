module Fog
  module Vcloud
    module Terremark
      module Ecloud
        class Server < Fog::Vcloud::Model

          identity :href, :Href

          ignore_attributes :xmlns, :xmlns_i, :xmlns_xsi, :xmlns_xsd

          attribute :type
          attribute :name
          attribute :status
          attribute :network_connections, :aliases => :NetworkConnectionSection, :squash => :NetworkConnection
          attribute :os, :aliases => :OperatingSystemSection
          attribute :virtual_hardware, :aliases => :VirtualHardwareSection
          attribute :storage_size, :size
          attribute :links, :aliases => :Link, :type => :array

          def friendly_status
            load_unless_loaded!
            case status
            when '0'
              'creating'
            when '2'
              'off'
            when '4'
              'on'
            else
              'unkown'
            end
          end

          def ready?
            load_unless_loaded!
            @status == '2'
          end

          def on?
            load_unless_loaded!
            @status == '4'
          end

          def off?
            load_unless_loaded!
            @status == '2'
          end

          def power_on
            power_operation( :power_on => :powerOn )
          end

          def power_off
            power_operation( :power_off => :powerOff )
          end

          def shutdown
            power_operation( :power_shutdown => :shutdown )
          end

          def power_reset
            power_operation( :power_reset => :reset )
          end

          def graceful_restart
            requires :href
            shutdown
            wait_for { off? }
            power_on
          end

          def delete
            requires :href
            connection.delete_vapp( href)
          end

          def name=(new_name)
            @name = new_name
            @changed = true
          end

          def cpus
            { :count => cpu_mess[:VirtualQuantity].to_i,
              :units => cpu_mess[:AllocationUnits] }
          end

          def cpus=(qty)
            @changed = true
            cpu_mess[:VirtualQuantity] = qty.to_s
          end

          def memory
            { :amount => memory_mess[:VirtualQuantity].to_i,
              :units => memory_mess[:VirtualQuantityUnits] }
          end

          def memory=(amount)
            @changed = true
            memory_mess[:VirtualQuantity] = amount.to_s
          end

          def disks
            disk_mess.map do |dm|
              { :number => dm[:AddressOnParent], :size => dm[:VirtualQuantity].to_i, :resource => dm[:HostResource] }
            end
          end

          def add_disk(size)
            if @disk_change == :deleted
              raise RuntimeError, "Can't add a disk w/o saving changes or reloading"
            else
              @disk_change = :added
              load_unless_loaded!
              virtual_hardware[:Item] << { :ResourceType => '17',
                                           :AddressOnParent => (disk_mess.map { |dm| dm[:AddressOnParent] }.sort.last.to_i + 1).to_s, 
                                           :VirtualQuantity => size.to_s }
            end
            true
          end

          def delete_disk(number)
            if @disk_change == :added
              raise RuntimeError, "Can't delete a disk w/o saving changes or reloading"
            else
              @disk_change = :deleted
              load_unless_loaded!
              unless number == 0
                virtual_hardware[:Item].delete_if { |vh| vh[:ResourceType] == '17' && vh[:AddressOnParent].to_i == number }
              end
            end
            true
          end

          def reload
            super
            reset_tracking
          end

          def save
            if new_record?
              requires :name
              puts "NOOP"
              return false
              #result = connection.instantiate_vapp_template( stuff )
              #merge_attributes(result.body)
            else
              if on?
                if @changed
                  raise RuntimeError, "Can't save cpu, name or memory changes while the VM is on."
                end
              end
              connection.configure_vapp( href, _compose_vapp_data )
            end
            reset_tracking
          end

          private

          def reset_tracking
            @disk_change = false
            @changed = false
            true
          end

          def _compose_vapp_data
            { :name   => name,
              :cpus   => cpus[:count],
              :memory => memory[:amount],
              :disks  => disks
            }
          end

          def memory_mess
            load_unless_loaded!
            virtual_hardware[:Item].detect { |item| item[:ResourceType] == "4" }
          end

          def cpu_mess
            load_unless_loaded!
            virtual_hardware[:Item].detect { |item| item[:ResourceType] == "3" }
          end

          def disk_mess
            load_unless_loaded!
            virtual_hardware[:Item].select { |item| item[:ResourceType] == "17" }
          end

          def power_operation(op)
            requires :href
            begin
              connection.send(op.keys.first, href + "/power/action/#{op.values.first}" )
            rescue Excon::Errors::InternalServerError => e
              #Frankly we shouldn't get here ...
              raise e unless e.to_s =~ /because it is already powered on/
            end
            true
          end

        end
      end
    end
  end
end