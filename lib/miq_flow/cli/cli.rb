# frozen_string_literal: true

require 'thor'
require_relative 'list.rb'

module MiqFlow
  # Implements common CLI methods
  module Cli
    def cli_setup(options={}, mode=[])
      MiqFlow::Settings.search_config_files()
      MiqFlow::Settings.process_environment_variables()
      MiqFlow::Settings.process_config_file(options['config'])
      MiqFlow::Settings.update_log_level(:debug) if options['verbose'] == true
      MiqFlow::Settings.update_log_level(:warn)  if options['quiet'] == true
      MiqFlow::Settings.update_clear_tmp(options['cleanup'])
      MiqFlow::Settings.update_workdir(options['workdir'])

      MiqFlow.validate(mode)
      MiqFlow.init()
      MiqFlow.prepare_repo()
    end

    # Implements CLI
    class MainCli < Thor
      include MiqFlow::Cli

      def self.exit_on_failure?
        true
      end

      class_option :verbose, type: :boolean, desc: 'Turn on verbose logging'
      class_option :quiet, type: :boolean, desc: 'Only show errors and warnings'
      class_option :cleanup, type: :boolean, desc: 'Clean up the working dir before exiting'
      class_option :workdir, type: :string, desc: 'Override the working directory'
      class_option :config, type: :string, alias: '-c', desc: 'Specify config file to load'

      desc 'list git|miq', 'Show summary information'
      subcommand 'list', MiqFlow::Cli::ListCli

      desc 'inspect BRANCH', 'Show detailed information about this Feature-Branch'
      option :short, type: :boolean, default: false, desc: 'Same as list'
      def inspect(name)
        cli_setup(options, %i[git])
        feature = MiqFlow::Feature.new(name, {})
        text = options[:short] ? feature.show_summary() : feature.show_details()
        puts text
        MiqFlow.tear_down()
      end

      desc 'deploy BRANCH', 'Deploy a Feature Branch'
      option :name, desc: 'specify domain identifier (default: 3rd segment of NAME, separated by \'-\')'
      option :priority, type: :numeric, desc: 'Not-yet-implemented'
      option :provider, desc: 'How to talk to ManageIQ (default: noop)'
      def deploy(branch)
        cli_setup(options, %i[git miq])
        miq_domain = options[:name] || branch.split(/-/)[2] || branch
        provider   = options.fetch(:provider, 'default')
        prio       = options[:miq_priority]

        opts = { feature_name: miq_domain, provider: provider }
        opts[:miq_priotiry] = prio
        feature = MiqFlow::Feature.new(branch, opts)
        feature.deploy()
        MiqFlow.tear_down()
      end
    end
  end
end
