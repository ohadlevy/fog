module Fog
  module Compute
    class Vsphere
      class Real
        def get_folder(path, datacenter_name)
          folder = get_raw_folder(path, datacenter_name)
          raise(Fog::Compute::Vsphere::NotFound) unless folder
          folder_attributes(folder, datacenter_name)
        end
        
        protected
        
        def get_raw_folder(path, datacenter_name)
          # The required path syntax - 'topfolder/subfolder/anotherfolder'
          path_ary = path.split('/')
          dc = get_raw_datacenter(datacenter_name)
          dc_root_folder = dc.vmFolder

          # Walk the tree resetting the folder pointer as we go
          folder = path_ary.inject(dc_root_folder) do |last_returned_folder, sub_folder|
            # JJM VIM::Folder#find appears to be quite efficient as it uses the
            # searchIndex It certainly appears to be faster than
            # VIM::Folder#inventory since that returns _all_ managed objects of
            # a certain type _and_ their properties.
            # NH: renamed some vars.
            sub = last_returned_folder.find(sub_folder, RbVmomi::VIM::Folder)
            raise ArgumentError, "Could not descend into #{sub_folder}.  Please check your path. #{path}" unless sub
            sub
          end
        end
        
        def folder_attributes(folder, datacenter_name)
          # Ugly but it's the only way to reget path?
          path = folder.path.each.inject([]) { |p,e| p << e.last } - ["Datacenters","vm", datacenter_name]
          path = path.join('/')
          {
            :id       => managed_obj_id(folder),
            :name     => folder.name,
            :parent   => folder.parent.name,
            :datacenter => datacenter_name,
            :path     => path, 
          }
        end
      end
    end
  end
end