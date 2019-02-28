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

      desc 'diff BRANCH', 'DEV: Show a diff between BRANCH and the current version in ManageIQ'
      def diff(name)
        cli_setup(options, %i[git api])
        data = {}
        text = []
        api = MiqFlow::ManageIQ.new
        feature = MiqFlow::Feature.new(name, {})
        changeset = feature.get_diff_paths()
        feature.miq_domain.each do |domain|
          paths = domain._limit_changeset(changeset)

          paths.each do |path|
            data[domain.name] = {}
            data[domain.name][path] = {api: {}, file: {}}

            data[domain.name][path][:file] = { path: path, content: File.read(File.join(feature.git_workdir, path))  }
          end

          api_obj = domain.changeset_as_uri(paths)
          api_data = api_obj.map do |o| 
            q = api.query_automate_model(o[:class], type: :method, attributes: %i[name data])
            data[domain.name][o[:path]][:api] = {raw: q, path: o[:path], content: q[:data]}
          end

          text << {api: api_data, file: file_data}
          #text << path
          #dom = ManageIQ.get_domain_content(path)
          #feat = Feature.get_file_content(patth)
          #text << Rugged.diff(feat, dom )
        end
        puts data.inspect
        MiqFlow.tear_down()
      end
      
    end
  end
end
