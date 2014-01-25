require 'spec_helper'

describe VSphereCloud::Resources::Datacenter do
  subject(:datacenter) { described_class.new(config) }

  let(:config) { instance_double('VSphereCloud::Config',
                                 client: client,
                                 datacenter_name: 'fake-datacenter-name',
                                 datacenter_vm_folder: 'fake-vm-folder',
                                 datacenter_template_folder: 'fake-template-folder',
                                 datacenter_clusters: { 'cluster1' => cluster_config1, 'cluster2' => cluster_config2 }
  ) }
  let(:client) { instance_double('VSphereCloud::Client') }
  let(:vm_folder) { instance_double('VSphereCloud::Resources::Folder') }
  let(:template_folder) { instance_double('VSphereCloud::Resources::Folder') }
  let(:datacenter_mob) { instance_double('VimSdk::Vim::Datacenter') }
  let(:cluster_mob1) { instance_double('VimSdk::Vim::Cluster') }
  let(:cluster_mob2) { instance_double('VimSdk::Vim::Cluster') }
  let(:cluster_config1) { instance_double('VSphereCloud::ClusterConfig') }
  let(:cluster_config2) { instance_double('VSphereCloud::ClusterConfig') }
  let(:resource_cluster1) { instance_double('VSphereCloud::Resources::Cluster', name: 'cluster1') }
  let(:resource_cluster2) { instance_double('VSphereCloud::Resources::Cluster', name: 'cluster2') }

  before do
    allow(client).to receive(:find_by_inventory_path).with('fake-datacenter-name').and_return(datacenter_mob)
    allow(VSphereCloud::Resources::Folder).to receive(:new).with(
                                                'fake-vm-folder', config).and_return(vm_folder)
    allow(VSphereCloud::Resources::Folder).to receive(:new).with(
                                                'fake-template-folder', config).and_return(template_folder)
    allow(client).to receive(:get_managed_objects).with(
                       VimSdk::Vim::ClusterComputeResource,
                       root: datacenter_mob, include_name: true).and_return(
                       {
                         'cluster1' => cluster_mob1,
                         'cluster2' => cluster_mob2,
                       }
                     )
    allow(client).to receive(:get_properties).with(
                       [cluster_mob1, cluster_mob2],
                       VimSdk::Vim::ClusterComputeResource,
                       VSphereCloud::Resources::Cluster::PROPERTIES,
                       ensure_all: true).and_return({ cluster_mob1 => {}, cluster_mob2 => {} })

    allow(VSphereCloud::Resources::Cluster).to receive(:new).with(
                                                 anything, cluster_config1, {}).and_return(resource_cluster1)
    allow(VSphereCloud::Resources::Cluster).to receive(:new).with(
                                                 anything, cluster_config2, {}).and_return(resource_cluster2)
  end

  describe '#mob' do
    context 'when mob is found' do
      it 'returns the datacenter mob' do
        expect(datacenter.mob).to eq(datacenter_mob)
      end
    end
    context 'when mob is not found' do
      before { allow(client).to receive(:find_by_inventory_path).with('fake-datacenter-name').and_return(nil) }
      it 'raises' do
        expect { datacenter.mob }.to raise_error(RuntimeError, 'Datacenter: fake-datacenter-name not found')
      end

    end
  end

  describe '#clusters' do
  end

  describe '#vm_folder' do
  end

  describe '#template_folder' do
  end

  describe '#mob' do
  end

  describe '#config' do
  end

  describe '#name' do
    it 'returns the datacenter name' do
      expect(datacenter.name).to eq('fake-datacenter-name')
    end
  end

  describe '#disk_path' do
  end

  #it "should create a datacenter" do
  #  dc_mob = double(:dc_mob)
  #  cluster_mob = double(:cluster_mob)
  #
  #  @client.should_receive(:find_by_inventory_path).with("TEST_DC").
  #      and_return(dc_mob)
  #  @client.should_receive(:get_managed_objects).
  #      with(VimSdk::Vim::ClusterComputeResource,
  #           {:root=>dc_mob, :include_name=>true}).
  #      and_return({"foo" => cluster_mob})
  #  @client.should_receive(:get_properties).
  #      with([cluster_mob], VimSdk::Vim::ClusterComputeResource,
  #           %w(name datastore resourcePool host), {:ensure_all => true}).
  #      and_return({cluster_mob => {:foo => :bar}})

  #folder_config = VSphereCloud::Config::FolderConfig.new
  #folder_config.vm = "vms"
  #folder_config.template = "templates"
  #folder_config.shared = false
  #cluster_config = VSphereCloud::Config::ClusterConfig.new("foo")
  #datastore_config = VSphereCloud::Config::DatastoreConfig.new
  #datastore_config.disk_path = "bosh_disks"

  #dc_config = double(:dc_config)
  #dc_config.stub(:name).and_return("TEST_DC")
  #dc_config.stub(:folders).and_return(folder_config)
  #dc_config.stub(:clusters).and_return({"foo" => cluster_config})
  #dc_config.stub(:datastores).and_return(datastore_config)

  #vm_folder = double(:vm_folder)
  #VSphereCloud::Resources::Folder.stub(:new).
  #    with(an_instance_of(VSphereCloud::Resources::Datacenter),
  #         "vms", false).
  #    and_return(vm_folder)
  #
  #template_folder = double(:template_folder)
  #VSphereCloud::Resources::Folder.stub(:new).
  #    with(an_instance_of(VSphereCloud::Resources::Datacenter),
  #         "templates", false).
  #    and_return(template_folder)
  #
  #cluster = double(:cluster)
  #cluster.stub(:name).and_return("foo")
  #VSphereCloud::Resources::Cluster.stub(:new).
  #    with(an_instance_of(VSphereCloud::Resources::Datacenter),
  #         cluster_config, {:foo => :bar}).
  #    and_return(cluster)
  #
  #datacenter = VSphereCloud::Resources::Datacenter.new(dc_config)
  #datacenter.mob.should == dc_mob
  #datacenter.clusters.should == {"foo" => cluster}
  #datacenter.vm_folder.should == vm_folder
  #datacenter.template_folder.should == template_folder
  #datacenter.config.should == dc_config
  #datacenter.name.should == "TEST_DC"
  #datacenter.disk_path.should == "bosh_disks"
  #end

  #end
end
