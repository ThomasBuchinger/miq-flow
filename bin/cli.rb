#!/usr/bin/env ruby
require 'thor'
require_relative '../lib/bootstrap.rb'

module GitFlow
  class Cli < Thor

    desc "list", "List Feature branches "
    def list()
      GitFlow.init()
      branches = GitFlow::GitMethods.get_remote_branches()
      puts branches.map{|b| GitFlow::Feature.new(b.name, {}).show_summary() }
    end

    desc "inspect NAME", "List domains"
    option :short, type: :boolean, default: false
    def inspect(name)
      GitFlow.init()
      feature = GitFlow::Feature.new(name, {})
      puts options[:short] ? feature.show_summary() : feature.show_details()
    end

    desc "deploy NAME", "Deploy a Feature Branch"
    option :domain, desc: "specify the automate domain to use (default: 3rd segment of NAME, seperted by '-')"
    option :export_name, desc: "name of the domain on the filesystem", alias: 'miq_fs_domain'
    option :priority, type: :numeric 
    option :provider, desc: "How to talk to ManageIQ (default: noop)"
    def deploy(name)
      GitFlow.init()
      miq_domain = options[:domain] || (name.split(/-/) || [])[2] || name
      provider   = options.fetch(:provider, 'default')

      opts = {:feature_name=>miq_domain, :provider=>provider}
      opts[:miq_priority]  = options[:priority]    unless options[:priority].nil?
      feature = GitFlow::Feature.new(name, opts)
      feature.deploy()
      GitFlow.tear_down()
    end

    desc 'devel1', 'Development NOOP command' 
    def devel1()
      GitFlow.init()
      feature_opts = { :feature_name=>'f1' }
      f1 = GitFlow::Feature.new('feature-1-f1', feature_opts)
      f1.deploy()
      GitFlow.tear_down()
    end
    desc 'devel2', 'Development ACTIVE command ' 
    def devel2()
      GitFlow.init()
      feature_opts = { :feature_name=>'base', :provider=>'docker', :miq_import_method=>:clean}
      master = GitFlow::Feature.new('master', feature_opts)
      master.deploy()
      feature_opts = { :feature_name=>'f1', :provider=>'docker' }
      f1 = GitFlow::Feature.new('feature-1-f1', feature_opts)
      f1.deploy()
      GitFlow.tear_down()
    end
  end
end
begin
  GitFlow::Cli.start()
rescue GitFlow::Error => e
  $logger.error(e.to_s)
  GitFlow.tear_down()
end
