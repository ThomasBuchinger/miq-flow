#!/usr/bin/env ruby
require 'thor'
require_relative '../lib/bootstrap.rb'

module GitFlow
  class Cli < Thor

    desc "list", "List Feature branches "
    def list()

    end

    desc "deploy NAME", "Deploy a Feature Branch"
    option :domain
    option :priority, :type => :numeric 
    option :provider
    def deploy(name)
      GitFlow.init()
      miq_domain   = options[:domain] || (name.split(/-/) || [])[2] || name
      provider     = GitFlow::MiqProvider::Appliance.new() if options[:provider] == 'local'
      provider     = GitFlow::MiqProvider::Docker.new()    if options[:provider] == 'docker'
      provider     = GitFlow::MiqProvider::Noop.new()      if options[:provider] == 'noop'

      feature_opts = {:miq_domain=>miq_domain, :provider=>provider}
      feature_opts[:miq_priority] = options[:priority] unless options[:priority].nil?
      feature_opts[:provider] = provider unless provider.nil?
      feature = GitFlow::Feature.new(name, $default_opts[:feature_defaults].merge(feature_opts))
      feature.deploy()
      GitFlow.tear_down()
    end

    desc 'devel1', 'Development NOOP command' 
    def devel1()
      GitFlow.init()
      feature_opts = { :miq_fs_domain=>'buc', :miq_domain=>'f1' }
      f1 = GitFlow::Feature.new('feature-1-f1', $default_opts[:feature_defaults].merge(feature_opts))
      f1.deploy()
      GitFlow.tear_down()
    end
    desc 'devel2', 'Development ACTIVE command ' 
    def devel2()
      GitFlow.init()
      provider = GitFlow::MiqProvider::Docker.new()
      feature_opts = { :miq_fs_domain=>'buc', :miq_domain=>'base', :provider=>provider, :miq_import_method=>:clean, :automate_dir=>'automate'}
      master = GitFlow::Feature.new('master', $default_opts[:feature_defaults].merge(feature_opts))
      master.deploy()
      feature_opts = { :miq_fs_domain=>'buc', :miq_domain=>'f1', :provider=>provider }
      f1 = GitFlow::Feature.new('feature-1-f1', $default_opts[:feature_defaults].merge(feature_opts))
      f1.deploy()
      GitFlow.tear_down()
    end
  end
end
GitFlow::Cli.start()
