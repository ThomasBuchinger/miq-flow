# frozen_string_literal: true

require 'thor'

module MiqFlow
  module Cli
    # Implements list subcommand
    class DomainCli < Thor
      include MiqFlow::Cli

      desc 'list', 'List existing Automate Domains in ManageIQ'
      def list
        cli_setup(options, %i[api])
        api = MiqFlow::ManageIQ.new
        puts api.list_domains
      end
    end
  end
end
