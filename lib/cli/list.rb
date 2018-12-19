#!/usr/bin/env ruby
require 'thor'

module GitFlow
  module Cli
    # Implements list subcommand
    class ListCli < Thor
      include GitFlow::Cli

      desc 'git', 'List avaliable Feature Branches'
      def git
        cli_setup()
        branches = GitFlow::GitMethods.get_remote_branches()
        text = branches.map{ |b| GitFlow::Feature.new(b.name, {}).show_summary() }
        puts text
        GitFlow.tear_down()
      end

      desc 'miq', 'List available Automate Domains in ManageIQ'
      def miq
        api = GitFlow::ManageIQ.new
        puts api.list_domains
      end
    end
  end
end
