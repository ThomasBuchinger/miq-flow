# frozen_string_literal: true

require 'spec_helper'
require 'miq_flow'
require 'miq_flow/cli'

RSpec.describe MiqFlow::Cli::MainCli, integration: true do
  let(:git_url){ ENV.fetch('GIT_URL', 'https://github.com/ThomasBuchinger/automate-example') }
  let(:miq_url){ ENV.fetch('MIQ_URL', 'https://localhost:8443/api') }

  before(:each) do
    $settings = { git: {}, miq: {} }
    MiqFlow::Config.set_defaults()
    MiqFlow::Config.update_searchpath([], replace: true)
    MiqFlow::Config.update_log_level(:no_log)
    MiqFlow::Config.update_naming(nil, 2)

    MiqFlow::Config.update_git(git_url, nil, nil, nil)
    MiqFlow::Config.update_miq_api(miq_url, 'admin', 'smartvm')
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
      MiqFlow::Config.update_git('https://github.com/invalid/not_a_repo.git', nil, nil, nil)
      expect{ subject.invoke(:branch, ['list']) }.to raise_error(MiqFlow::GitError)
    end
  end

  # context 'Rake Commands: Docker', git: true, docker: true do
  #   it 'deploy' do
  #     expect{ subject.invoke(:deploy, ['feature-1-f1']) }.to output(/Your database has been updated./).to_stdout
  #   end
  # end

  context 'API Commands: Mock', mock: true do
    require_relative 'api_mock.rb'
    let!(:domain_list_stub) do
      stub_request(:get, %r{/automate/})
        .with(query: hash_including('depth' => 1))
        .to_return(status: 200, body: JSON.generate(domain_list_data))
    end

    let!(:server_stub) do
      stub_request(:get, %r{/api/automate/})
    end

    let!(:ae_method_stub) do
      stub_request(:get, %r{/automate/feat_.*})
        .with(query: hash_including('depth' => '-1'))
        .to_return(status: 200, body: JSON.generate(ae_method_data))
    end

    shared_examples_for 'ManageIQ API' do
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
    it_behaves_like('ManageIQ API')

    # it 'domain list' do
    #   expect{ subject.invoke(:domain, ['list'])}.to output(/ManageIQ/).to_stdout
    # end
    it 'branch diff feature-1-f1' do
      expect{ subject.invoke(:branch, ['diff', 'feature-1-f1']) }.to output(/^diff --git /).to_stdout
    end
  end
end
