require 'pathname'
require 'yaml'
module GitFlow
  module MiqMethods
    # ManageIQ related Methods, that are not plugable
    module MiqUtils
      DOMAIN_FILE_NAME = '__domain__.yaml'.freeze

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
    end
  end
end
