# frozen_string_literal: true

require 'thor'

module MiqFlow
  module Cli
    # Implements list subcommand
    class ListCli < Thor
      include MiqFlow::Cli

      desc 'git', 'List avaliable Feature Branches'
      def git
        cli_setup(options, %i[git])
        branches = MiqFlow::GitMethods.get_remote_branches()
        text = branches.map{ |b| MiqFlow::Feature.new(b.name, {}).show_summary() }
        puts text
        MiqFlow.tear_down()
      end

      desc 'miq', 'List available Automate Domains in ManageIQ'
      def miq
        cli_setup(options, %i[api])
        api = MiqFlow::ManageIQ.new
        puts api.list_domains
      end
    end
  end
end
