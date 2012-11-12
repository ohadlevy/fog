module Fog
  module Compute
    class Vsphere
      class Real
        # Grabs all sub folders within a given path folder. 
        #
        # ==== Parameters
        # * filters<~Hash>:
        #   * :datacenter<~String> - *REQUIRED* Your datacenter where you're
        #     looking for folders. Example: 'my-datacenter-name' (passed if you
        #     are using the models/collections) 
        #       eg: vspconn.datacenters.first.vm_folders('mypath')
        #   * :path<~String> - Your path where you're looking for
        #     more folders, if return = none you will get an error. If you don't
        #     define it will look in the main datacenter folder for any folders 
        #     in that datacenter.
        #
        # Example Usage Testing Only: 
        #  vspconn = Fog::Compute[:vsphere]
        #  mydc = vspconn.datacenters.first
        #  folders = mydc.vm_folders
        #
        def list_vmfolders(filters = {})
          path = filters[:path]
          path ||= ''
          datacenter_name = filters[:datacenter]
          folders = get_raw_vmfolders(path, datacenter_name)
          raise(Fog::Compute::Vsphere::NotFound) unless folders.is_a? Array
          folder_list = folders.each.inject({}) do |h,f|
            h[f.name] = folder_attributes(f, datacenter_name)
            h
          end
          raise(Fog::Compute::Vsphere::NotFound, "Folder #{path} has no subfolders") if folder_list.empty?
          folder_list
        end
        
        protected
        
        def get_raw_vmfolders(path, datacenter_name)
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
          
          folder_list = folder.children.each.inject([]) do |a,e|
            a << e if e.class.to_s == "Folder"
            a
          end
        end
        
        def folder_attributes(folder, datacenter_name)
          # Ugly but it's the only way to get flat 
          # relative path from Datacenter
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