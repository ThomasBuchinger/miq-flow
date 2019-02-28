# frozen_string_literal: true

require 'pathname'
require 'yaml'
module MiqFlow
  module MiqMethods
    # ManageIQ related Methods, that are not plugable
    module MiqUtils
      DOMAIN_FILE_NAME = '__domain__.yaml'
      INVALID_CHARS = /[^A-Za-z0-9_\-\.$]/.freeze

      # Find and read Automate domains
      # Search PATH for __domain__.yaml files, indicating a ManageIQ Automate Domain
      #
      # @param [String] path path to search in
      # @return [Array<Hash>] information about the domain
      def find_domain_files(path)
        Dir.glob(File.join(path, '**', DOMAIN_FILE_NAME)).map do |file|
          h = {}
          dir = File.dirname(file)
          h[:full_path] = dir
          h[:domain_name] = File.basename(dir)
          h[:relative_path] = Pathname.new(dir).relative_path_from(Pathname.new(path)).to_s
          h[:domain] = YAML.load_file(file)
          $logger.debug("Found domain at: #{h[:relative_path]}")
          h
        end
      end

      def split_branch_name(name, separator)
        current_index = 0
        sub_str = []
        loop do
          index = separator.map{ |s| name.index(s, current_index) }.compact.min
          length = (index || name.length) - current_index
          sub_str << name.slice(current_index, length)
          break if index.nil?

          current_index = index + 1
        end
        sub_str
      end

      def normalize_domain_name(name)
        name.gsub(INVALID_CHARS, '_')
      end

      def name_from_branch(name, index: nil, separator: nil)
        # branch_map = {
        #   'master': 'prod',
        #   'develop': 'dev'
        # }
        # return branch_map[name] if branch_map.key?(name)
        separator ||= $settings[:naming_separator]
        index ||= $settings[:naming_index]
        name = name.gsub("#{@remote_name}/", '') unless @remote_name.nil?

        domain = split_branch_name(name, separator).fetch(index, nil)
        return normalize_domain_name(domain) unless domain.nil? || domain.empty?

        normalize_domain_name(name)
      end

      def method_to_uri(path)
        return path unless path.include?('__methods__') && path.include?('.rb')


        index = path.index(".class#{File::SEPARATOR}__methods__")
        class_uri = path[0...index]
        name = path[(index+19)..-4]
        { class: class_uri, name: name, klass: :method, path: path }
      end
      def instance_to_uri(path)
        return path unless path.include?('.yaml') &&  path.include?('__methods__')

        # path.gsub(".class#{File::SEPARATOR}__methods__", '').chomp('.yaml')
        nil
      end
      def class_to_uri(path)
        return path unless path.include?('__class__.yaml')

        # path.gsub(".class#{File::SEPARATOR}", '').chomp('.rb')
        nil
      end
      def namespace_to_uri(path)
        return path unless path.include?('.rb')

        # path.gsub(".class#{File::SEPARATOR}__methods__", '').chomp('.rb')
        nil
      end
    end
  end
end
