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

      class_option :verbose, type: :boolean, default: false, desc: 'Turn on verbose logging'
      class_option :quiet, type: :boolean, default: false, desc: 'Only show errors and warnings'
      class_option :silent, type: :boolean, default: false, desc: 'Do not output anything'
      class_option :cleanup, type: :boolean, desc: 'Clean up the working dir before exiting'
      class_option :workdir, type: :string, desc: 'Override the working directory'
      class_option :config, type: :string, alias: '-c', desc: 'Specify config file to load'

      class_option :git_url, type: :string, desc: 'Git clone URL for remote repositories'
      class_option :git_path, type: :string, desc: 'path to a local git repositories'
      class_option :git_user, type: :string, desc: 'Username for remote repositories'
      class_option :git_password, type: :string, desc: 'Password/token for remote repositories'

      class_option :miq_url, type: :string, desc: 'ManageIQ API URL. (e.g. https://localhost/api)'
      class_option :miq_user, type: :string, desc: 'ManageIQ API User. (default: admin)'
      class_option :miq_password, type: :string, desc: 'Passwork/login-token for the ManageIQ API User'

      desc 'list branches|domains', 'Show summary information'
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
