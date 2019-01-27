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

      def split_branch_name(name, separator=nil)
        separator = ['-', '/'] if separator.nil?
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
    end
  end
end
