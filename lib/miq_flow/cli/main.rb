# frozen_string_literal: true

require 'thor'
require_relative 'branch.rb'
require_relative 'domain.rb'

module MiqFlow
  # Implements common CLI methods
  module Cli
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
      class_option :git_separator, type: :string, desc: 'List of characters separating part of your ' \
                                                       'branch naming convention'
      class_option :git_index, type: :numeric, desc: 'Index the NAME par of your branch naming convenion'

      class_option :miq_url, type: :string, desc: 'ManageIQ API URL. (e.g. https://localhost/api)'
      class_option :miq_user, type: :string, desc: 'ManageIQ API User. (default: admin)'
      class_option :miq_password, type: :string, desc: 'Passwork/login-token for the ManageIQ API User'

      desc 'branch', 'Branch commands'
      subcommand 'branch', MiqFlow::Cli::BranchCli

      desc 'domain', 'Domain commands'
      subcommand 'domain', MiqFlow::Cli::DomainCli

      desc 'deploy BRANCH', 'Deploy a Feature Branch'
      option :name, desc: 'specify domain identifier (default: 2nd segment of NAME, separated by \'-\')'
      option :priority, type: :numeric, desc: 'Not-yet-implemented'
      option :provider, desc: 'How to talk to ManageIQ (default: noop)'
      def deploy(branch)
        cli_setup(options, %i[git miq])
        miq_domain = options[:name]
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
