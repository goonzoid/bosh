module VSphereCloud
  class Resources

    # Datacenter resource.
    class Datacenter
      include VimSdk

      attr_accessor :config
      attr_accessor :clusters
      attr_accessor :template_folder
      attr_accessor :vm_folder

      def initialize(config)
        @config = config

        datacenter_mob = @client.find_by_inventory_path(name)

        raise "Datacenter: #{name} not found" if datacenter_mob.nil?

        @vm_folder = Folder.new(config.datacenter_vm_folder, config)
        @template_folder = Folder.new(config.datacenter_template_folder, config)

        cluster_mobs = @client.get_managed_objects(
          Vim::ClusterComputeResource, root: datacenter_mob, include_name: true)
        cluster_mobs.delete_if { |name, _| !config.datacenter_clusters.has_key?(name) }
        cluster_mobs = Hash[*cluster_mobs.flatten]

        clusters_properties = @client.get_properties(
          cluster_mobs.values, Vim::ClusterComputeResource,
          Cluster::PROPERTIES, :ensure_all => true)

        @clusters = {}
        config.datacenter_clusters.each do |name, cluster_config|
          cluster_mob = cluster_mobs[name]
          raise "Can't find cluster: #{name}" if cluster_mob.nil?
          cluster_properties = clusters_properties[cluster_mob]
          if cluster_properties.nil?
            raise "Can't find properties for cluster: #{name}"
          end
          cluster = Cluster.new(self, cluster_config, cluster_properties)
          @clusters[cluster.name] = cluster
        end
      end

      def mob
        mob = @config.client.find_by_inventory_path(name)
        raise "Datacenter: #{name} not found" if mob.nil?
        mob
      end

      def name
        @config.datacenter_name
      end

      def disk_path
        @config.datastores.disk_path
      end

      def inspect
        "<Datacenter: #@mob / #{@config.name}>"
      end
    end
  end
end
