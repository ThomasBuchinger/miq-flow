require 'pathname'
require 'yaml'
module GitFlow
  module MiqMethods
    module MiqUtils
      DOMAIN_FILE_NAME = "__domain__.yaml"

      def find_domain_files(path)
        Dir.glob(File.join(path, "**", DOMAIN_FILE_NAME)).map do |file|
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


