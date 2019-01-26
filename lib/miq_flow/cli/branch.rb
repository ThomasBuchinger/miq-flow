# frozen_string_literal: true

require 'thor'

module MiqFlow
  module Cli
    # Implements list subcommand
    class BranchCli < Thor
      include MiqFlow::Cli

      desc 'list', 'List avaliable Feature Branches'
      def list
        cli_setup(options, %i[git])
        branches = MiqFlow::GitMethods.get_remote_branches()
        text = branches.map{ |b| MiqFlow::Feature.new(b.name, {}).show_summary() }
        puts text
        MiqFlow.tear_down()
      end

      desc 'inspect BRANCH', 'Show detailed information about this Feature-Branch'
      option :short, type: :boolean, default: false, desc: 'Same as list'
      def inspect(name)
        cli_setup(options, %i[git])
        feature = MiqFlow::Feature.new(name, {})
        text = options[:short] ? feature.show_summary() : feature.show_details()
        puts text
        MiqFlow.tear_down()
      end
    end
  end
end
