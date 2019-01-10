# frozen_string_literal: true

require 'spec_helper.rb'
require 'bootstrap.rb'
require 'cli/cli.rb'

RSpec.describe GitFlow::Cli::MainCli do
  let(:git_url){ ENV.fetch('GIT_URL', 'https://github.com/ThomasBuchinger/automate-example') }
  let(:miq_url){ ENV.fetch('MIQ_URL', 'https://localhost:8443/api') }

  before(:each) do
    $settings = { git: {}, miq: {} }
    GitFlow::Settings.set_defaults()
    GitFlow::Settings.update_log_level(:unknown)
    
    GitFlow::Settings.update_git(git_url, nil, nil, nil)
    GitFlow::Settings.update_miq_api(miq_url, 'admin', 'smartvm')
  end

  context 'General handling' do
    it 'does display help' do
      expect{ subject.invoke(:help) }.to output(/Commands:/).to_stdout
    end
    it 'exits 1 on missing command' do
      expect{ subject.invoke(:not_existing) }.to raise_error(/Missing Thor class/)
    end
  end

  context 'Basic Commands' do
    it 'list git' do
      expect{ subject.invoke(:list, ['git']) }.to output(%r{origin/feature-1-f1}).to_stdout
    end
    it 'inspect' do
      expect{ subject.invoke(:inspect, ['feature-1-f1']) }.to output(/Feature: f1 on branch feature-1-f1/).to_stdout
    end
    it 'deploy - noop' do
      expect{ subject.invoke(:deploy, ['feature-1-f1', '--provider', 'noop']) }.to_not raise_error
    end
  end

  context 'Git Commands' do
    it{ is_expected().to be_truthy }
  end

  context 'Rake Commands: Docker' do
    # it 'list miq' do
    #   expect{ subject.invoke(:list, ['miq']) }.to output(/ManageIQ/).to_stdout
    # end
    it 'deploy' do
      expect{ subject.invoke(:deploy, []).to_output(/Your database has been updated./).to_stdout }
    end
  end

  shared_examples_for 'ManageIQ API' do
    it 'list miq' do
      expect{ subject.invoke(:list, ['miq']).to_output(/ManageIQ/).to_stdout }
    end
  end

  context 'API Commands: Mock' do
    let(:domain_list_stub) do
      domains = [
        { 'href'=>"#{miq_url}/automate/1",'klass'=>'MiqAeDomain','id'=>'1','name'=>'ManageIQ','updated_on'=>Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),'description'=>nil,'priority'=>'1','enabled'=>true,'tenant_id'=>'1' }
      ]
      domain_list = { 'name' => 'automate', 'subcount' => domains.length, 'resources'=> domains }
      stub_request(:post, "#{miq_url}/automate/").
        with(query: hash_including({'depth'=>1})).
        to_return(status: 200, body: JSON.generate(domain_list))
    end
    it_behaves_like('ManageIQ API')
  end


end
