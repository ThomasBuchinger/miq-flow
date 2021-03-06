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
        text = branches.map{ |b| show_feature_short(MiqFlow::Feature.new(b.name, {})) }
        puts text
        MiqFlow.tear_down()
      end

      desc 'inspect BRANCH', 'Show detailed information about this Feature-Branch'
      option :short, type: :boolean, default: false, desc: 'Same as list'
      def inspect(name)
        cli_setup(options, %i[git])
        feature = MiqFlow::Feature.new(name, {})
        text = options[:short] ? show_feature_short(feature) : show_feature_long(feature)
        puts text
        MiqFlow.tear_down()
      end

      desc 'diff BRANCH', 'DEV: Show diff between BRANCH and the current version in ManageIQ'
      def diff(name)
        cli_setup(options, %i[git api])
        api = MiqFlow::ManageIQ.new
        feature = MiqFlow::Feature.new(name, {})
        feature.checkout()
        data = get_diff_data(feature, api)

        # get patches
        text = data.map do |key, value|
          Rugged::Patch.from_strings(
            value[:content],
            value[:data],
            new_path: key.to_s, old_path: value[:path]
          ).to_s
        end
        puts text
        MiqFlow.tear_down()
      end
    end
  end
end
