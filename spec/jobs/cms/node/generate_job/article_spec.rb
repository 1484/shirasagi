require 'spec_helper'

describe Cms::Node::GenerateJob, dbscope: :example do
  let(:site)   { cms_site }
  let(:layout) { create_cms_layout }
  let(:node)   { create :article_node_page, cur_site: cms_site, layout_id: layout.id }
  let!(:page)  { create :article_page, cur_site: cms_site, cur_node: node, layout_id: layout.id }

  before do
    Cms::Task.create!(site_id: site.id, node_id: nil, name: 'cms:generate_nodes', state: 'ready')
    Cms::Task.create!(site_id: site.id, node_id: node.id, name: 'cms:generate_nodes', state: 'ready')
  end

  describe "#perform without node" do
    before do
      described_class.bind(site_id: site).perform_now
    end

    it do
      expect(File.exist?("#{node.path}/index.html")).to be_truthy

      expect(Cms::Task.count).to eq 2
      Cms::Task.where(site_id: site.id, node_id: nil, name: 'cms:generate_nodes').first.tap do |task|
        expect(task.state).to eq 'completed'
        expect(task.started).not_to be_nil
        expect(task.closed).not_to be_nil
        expect(task.total_count).to eq 0
        expect(task.current_count).to eq 0
        expect(task.logs).to include(include("#{node.url}index.html"))
        expect(task.node_id).to be_nil
        # logs are saved in a file
        expect(::File.exists?(task.log_file_path)).to be_truthy
        # and there are no `logs` field
        expect(task[:logs]).to be_nil
      end
      Cms::Task.where(site_id: site.id, node_id: node.id, name: 'cms:generate_nodes').first.tap do |task|
        expect(task.state).to eq 'ready'
      end

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)
      end
    end
  end

  describe "#perform with node" do
    before do
      described_class.bind(site_id: site, node_id: node).perform_now
    end

    it do
      expect(File.exist?("#{node.path}/index.html")).to be_truthy

      expect(Cms::Task.count).to eq 2
      Cms::Task.where(site_id: site.id, node_id: nil, name: 'cms:generate_nodes').first.tap do |task|
        expect(task.state).to eq 'ready'
      end
      Cms::Task.where(site_id: site.id, node_id: node.id, name: 'cms:generate_nodes').first.tap do |task|
        expect(task.state).to eq 'completed'
        expect(task.started).not_to be_nil
        expect(task.closed).not_to be_nil
        expect(task.total_count).to eq 0
        expect(task.current_count).to eq 0
        expect(task.logs).to include(include("#{node.url}index.html"))
        expect(task.node_id).to eq node.id
      end

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(/INFO -- : .* Completed Job/)
      end
    end
  end

  describe "#perform with generate_lock" do
    before do
      @save_config = SS.config.cms.generate_lock
      SS::Config.replace_value_at(:cms, 'generate_lock', { 'disable' => false, 'options' => ['1.hour'] })
      site.set(generate_lock_until: Time.zone.now + 1.hour)

      described_class.bind(site_id: site).perform_now
    end

    after do
      SS::Config.replace_value_at(:cms, 'generate_lock', @save_config)
    end

    it do
      expect(File.exist?("#{node.path}/index.html")).to be_falsey

      expect(Cms::Task.count).to eq 2
      Cms::Task.where(site_id: site.id, node_id: nil, name: 'cms:generate_nodes').first.tap do |task|
        expect(task.state).to eq 'completed'
        expect(task.started).not_to be_nil
        expect(task.closed).not_to be_nil
        expect(task.total_count).to eq 0
        expect(task.current_count).to eq 0
        expect(task.logs).not_to include(include("#{node.url}index.html"))
        expect(task.node_id).to be_nil
        # logs are saved in a file
        expect(::File.exists?(task.log_file_path)).to be_truthy
        # and there are no `logs` field
        expect(task[:logs]).to be_nil
      end
      Cms::Task.where(site_id: site.id, node_id: node.id, name: 'cms:generate_nodes').first.tap do |task|
        expect(task.state).to eq 'ready'
      end

      expect(Job::Log.count).to eq 1
      Job::Log.first.tap do |log|
        expect(log.logs).to include(/INFO -- : .* Started Job/)
        expect(log.logs).to include(include(I18n.t('mongoid.attributes.ss/addon/generate_lock.generate_locked')))
        expect(log.logs).to include(/INFO -- : .* Completed Job/)
      end
    end
  end
end
