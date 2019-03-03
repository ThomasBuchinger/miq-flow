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
        feature.checkout()
        feature.miq_domain.each do |domain|
          paths = domain._limit_changeset(changeset)

          # find file data
          file_data = paths.map{ |path| { path: path, content: File.read(File.join(feature.git_workdir, path))} }

          # find API data
          api_obj = domain.changeset_as_uri(paths)
          api_data = api_obj.map do |o| 
            q = api.query_automate_model(o[:class], type: :method, attributes: %i[name data])
            q.select!{|m| m['name'] == o[:name]  }
            if q.length != 1
              $logger.warn("Unable to find method via API: #{o[:path]}") if q.length == 0
              $logger.warn("Ambigiuos method name: #{o[:path]}") if q.length > 1
              next {raw: '', path: 'not found', content: ''}
            end

            {raw: q[0], path: o[:path], content: q[0]['data']}
          end

          # group_by_path
          data[domain.name] =  file_data.concat(api_data).group_by{|e| File.basename(e[:path]) }
          text << data[domain.name].map do |p, d| 
            Rugged::Patch.from_strings(
              d.fetch(0, {})[:content],
              d.fetch(1, {})[:content],
              {old_path: "git/#{p}", new_path: "api/#{p}"}
            ).to_s
          end
        end
        puts data.inspect
        puts "------"
        puts text.flatten
        MiqFlow.tear_down()
      end
      
    end
  end
end
