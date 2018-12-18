#!/usr/bin/env ruby
require 'thor'
require_relative 'list.rb'

module GitFlow
  # Implements common CLI methods
  module Cli
    def cli_setup(options={})
      GitFlow::Settings.process_config_file(options['config'])
      GitFlow::Settings.update_log_level(:debug) if options['verbose'] == true
      GitFlow::Settings.update_log_level(:warn)  if options['quiet'] == true
      GitFlow::Settings.update_clear_tmp(options['cleanup'])
      GitFlow::Settings.update_workdir(options['workdir'])

      GitFlow.init()
      GitFlow.prepare_repo()
    end

    # Implements CLI
    class MainCli < Thor
      include GitFlow::Cli

      class_option :verbose, type: :boolean, desc: 'Turn on verbose logging'
      class_option :quiet, type: :boolean, desc: 'Only show errors and warnings'
      class_option :cleanup, type: :boolean, desc: 'Clean up the working dir before exiting'
      class_option :workdir, type: :string, desc: 'Override the working directory'
      class_option :config, type: :string, alias: '-c', desc: 'Specify config file to load'

      desc 'list BRANCH|DOMAIN', 'Show summary information'
      subcommand 'list', GitFlow::Cli::ListCli

      desc 'inspect BRANCH', 'Show detailed information about this Feature-Branch'
      option :short, type: :boolean, default: false, desc: 'Same as list'
      def inspect(name)
        cli_setup()
        feature = GitFlow::Feature.new(name, {})
        text = options[:short] ? feature.show_summary() : feature.show_details()
        puts text
        GitFlow.tear_down()
      end

      desc 'deploy BRANCH', 'Deploy a Feature Branch'
      option :name, desc: 'specify domain identifier (default: 3rd segment of NAME, separated by \'-\')'
      option :priority, type: :numeric, desc: 'Not-yet-implemented'
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
    end
  end
end
