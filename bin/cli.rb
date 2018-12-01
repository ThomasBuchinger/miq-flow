#!/usr/bin/env ruby
require 'thor'
require_relative '../lib/bootstrap.rb'

module GitFlow
  # Implements the CLI interface
  class Cli < Thor
    class_option :verbose, type: :boolean, desc: 'Turn on verbose logging'
    class_option :quiet, type: :boolean, desc: 'Only show errors and warnings'
    class_option :cleanup, type: :boolean, desc: 'Clean up the working dir before exiting'
    class_option :workdir, type: :string, desc: 'Override the working directory'
    class_option :config, type: :string, alias: '-c', desc: 'Specify config file to load'

    no_commands do
      def cli_setup
        GitFlow::Settings.process_config_file(options['config'])
        GitFlow::Settings.update_log_level(:debug) if options['verbose'] == true
        GitFlow::Settings.update_log_level(:warn)  if options['quiet'] == true
        GitFlow::Settings.update_clear_tmp(options['cleanup'])
        GitFlow::Settings.update_workdir(options['workdir'])

        GitFlow.init()
      end
    end

    desc 'list', 'List Feature branches'
    def list
      cli_setup()
      branches = GitFlow::GitMethods.get_remote_branches()
      text = branches.map{ |b| GitFlow::Feature.new(b.name, {}).show_summary() }
      puts text
      GitFlow.tear_down()
    end

    desc 'inspect NAME', 'List domains'
    option :short, type: :boolean, default: false
    def inspect(name)
      cli_setup()
      feature = GitFlow::Feature.new(name, {})
      text = options[:short] ? feature.show_summary() : feature.show_details()
      puts text
      GitFlow.tear_down()
    end

    desc 'deploy BRANCH', 'Deploy a Feature Branch'
    option :name, desc: 'specify domain identifier (default: 3rd segment of NAME, separated by \'-\')'
    option :priority, type: :numeric
    option :provider, desc: 'How to talk to ManageIQ (default: noop)'
    def deploy(branch)
      cli_setup()
      miq_domain = options[:name] || branch.split(/-/)[2] || branch
      provider   = options.fetch(:provider, 'default')
      prio       = options[:miq_priority]

      opts = { feature_name: miq_domain, provider: provider }
      opts[:miq_priotiry] = prio
      feature = GitFlow::Feature.new(branch, opts)
      feature.deploy()
      GitFlow.tear_down()
    end

    desc 'devel1', 'Development NOOP command'
    def devel1
      cli_setup()
      feature_opts = { feature_name: 'f1' }
      f1 = GitFlow::Feature.new('feature-1-f1', feature_opts)
      f1.deploy()
      GitFlow.tear_down()
    end

    desc 'devel2', 'Development ACTIVE command'
    def devel2
      cli_setup()
      feature_opts = { feature_name: 'base', provider: 'docker', miq_import_method: :clean }
      master = GitFlow::Feature.new('master', feature_opts)
      master.deploy()
      feature_opts = { feature_name: 'f1', provider: 'docker' }
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
