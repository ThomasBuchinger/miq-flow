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

      desc 'diff BRANCH', 'DEV: Show diff between BRANCH and the current version in ManageIQ'
      def diff(name)
        cli_setup(options, %i[git api])
        api = MiqFlow::ManageIQ.new
        feature = MiqFlow::Feature.new(name, {})
        feature.checkout()
        data = {}

        # Get base data from MaangeIQ
        feature.miq_domain.each do |domain|
          $logger.debug("Searching AeMethods in #{domain.name}")
          api_data = api.query_automate_model(domain.name, type: :method, attributes: %i[name data location])
          api_data.each do |d|
            key = d["fqname"].to_sym
            data[key] = { 
              api_data: d['data'],
              location: d['location'],
              domain: d['fqname'].split('/')[1],
              name: d['fqname'].split('/')[-1],
              class: d['fqname'].split('/')[-2],
              namespace: d['fqname'].split('/')[2..-3].join('/'),
              export_dir: domain.export_dir,
              export_name: domain.export_name
            }
          end
        end

        # Get git data
        patches = data.map do |key, value|
          path = File.join(
                   feature.git_workdir,
                   value[:export_dir],
                   value[:export_name],
                   value[:namespace],
                   "#{value[:class]}.class",
                   '__methods__',
                   "#{value[:name]}.rb"
                 )
          data[key][:file_path] = path
          data[key][:file_data] = File.exists?(path) ? File.read(path) : ''

          Rugged::Patch.from_strings(
            value[:file_data],
            value[:api_data],
            {new_path: key.to_s, old_path: value[:file_path]}
          ).to_s
        end
        puts patches
        MiqFlow.tear_down()
      end
    end
  end
end
