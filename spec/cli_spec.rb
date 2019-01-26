# frozen_string_literal: true

require 'spec_helper'
require 'miq_flow'
require 'miq_flow/cli'

RSpec.describe MiqFlow::Cli::MainCli, integration: true do
  let(:git_url){ ENV.fetch('GIT_URL', 'https://github.com/ThomasBuchinger/automate-example') }
  let(:miq_url){ ENV.fetch('MIQ_URL', 'https://localhost:8443/api') }

  before(:each) do
    $settings = { git: {}, miq: {} }
    MiqFlow::Settings.set_defaults()
    MiqFlow::Settings.update_searchpath([], replace: true)
    MiqFlow::Settings.update_log_level(:no_log)

    MiqFlow::Settings.update_git(git_url, nil, nil, nil)
    MiqFlow::Settings.update_miq_api(miq_url, 'admin', 'smartvm')
  end

  context 'General handling' do
    it 'does display help' do
      expect{ subject.invoke(:help) }.to output(/Commands:/).to_stdout
    end
    it 'invalid command: exits with 1' do
      expect{ subject.invoke(:not_existing) }.to raise_error(/Missing Thor class/)
    end
    it 'invalid git configuraion: exits with 3' do
      $settings[:git] = {}
      expect{ subject.invoke(:branch, ['list']) }.to raise_error(MiqFlow::ConfigurationError)
    end
    it 'invalid api configuration: exiths with 3' do
      $settings[:miq] = {}
      expect{ subject.invoke(:domain, ['list']) }.to raise_error(MiqFlow::ConfigurationError)
    end
  end

  context 'Basic Commands', git: true do
    it 'branch list' do
      expect{ subject.invoke(:branch, ['list']) }.to output(%r{origin/feature-1-f1}).to_stdout
    end
    it 'branch inspect' do
      expect do
        subject.invoke(:branch, ['inspect', 'feature-1-f1'])
      end.to output(/Feature: f1 on branch feature-1-f1/).to_stdout
    end
    it 'deploy - noop' do
      expect{ subject.invoke(:deploy, ['feature-1-f1', '--provider', 'noop']) }.to_not raise_error
    end
  end

  context 'Git Commands', git: true do
    it 'exits 11 for invalid repositories' do
      MiqFlow::Settings.update_git('https://github.com/invalid/not_a_repo.git', nil, nil, nil)
      expect{ subject.invoke(:branch, ['list']) }.to raise_error(MiqFlow::GitError)
    end
  end

  context 'Rake Commands: Docker', git: true, docker: true do
    it 'deploy' do
      expect{ subject.invoke(:deploy, []).to_output(/Your database has been updated./).to_stdout }
    end
  end

  shared_examples_for 'ManageIQ API' do
    it 'domain list' do
      expect{ subject.invoke(:domain, ['list']).to_output(/ManageIQ/).to_stdout }
    end
  end

  context 'API Commands: Mock', mock: true do
    let(:domain_list_stub) do
      domains = [
        { 'href' => "#{miq_url}/automate/1", 'klass' => 'MiqAeDomain', 'id' => '1', 'name' => 'ManageIQ', 'updated_on' => Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'), 'description' => nil, 'priority' => '1', 'enabled' => true, 'tenant_id' => '1' } # rubocop:disable Metrics/LineLength
      ]
      domain_list = { 'name' => 'automate', 'subcount' => domains.length, 'resources' => domains }

      stub_request(:get, "#{miq_url}/automate/")
        .with(query: hash_including('depth' => 1))
        .to_return(status: 200, body: JSON.generate(domain_list))
    end

    let!(:server_stub) do
      stub_request(:get, %r{/api/automate/})
    end

    it_behaves_like('ManageIQ API')
    it 'handles 500 codes' do
      server_stub.to_return(status: 500)
      expect{ subject.invoke(:domain, ['list']) }.to raise_error(MiqFlow::BadResponseError)
    end
    it 'handles invalid Credentials' do
      server_stub.to_return(status: 403)
      expect{ subject.invoke(:domain, ['list']) }.to raise_error(MiqFlow::BadResponseError)
    end
    it 'handles connection reset' do
      server_stub.to_raise(Errno::ECONNREFUSED)
      expect{ subject.invoke(:domain, ['list']) }.to raise_error(MiqFlow::ConnectionError)
    end
    it 'handles timeout' do
      server_stub.to_timeout
      expect{ subject.invoke(:domain, ['list']) }.to raise_error(MiqFlow::ConnectionError)
    end
  end
end
