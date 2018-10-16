#!/usr/bin/env ruby
require 'thor'
require_relative '../runner.rb' # This is a temporary solution only
require_relative '../custom.rb' # This is a temporary solution only

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
      miq_domain   = options[:domain] || (name.split(/-/) || [])[2] || name
      provider     = nil
      provider     = GitFlow::MiqProvider::Appliance.new() if options[:provider] == 'local'
      provider     = provider ||  GitFlow::MiqProvider::Docker.new()

      feature_opts = {:miq_domain=>miq_domain, :provider=>provider}
      feature_opts[:miq_priority] = options[:priority] unless options[:priority].nil?
      feature = GitFlow::Feature.new(name, feature_opts)
      feature.deploy()
    end

    desc 'devel1', 'Development command' 
    def devel1()
      f1 = GitFlow::Feature.new('feature-1-f1', miq_domain: 'buc')
      f1.deploy()
    end

  end
end
GitFlow::Cli.start()
