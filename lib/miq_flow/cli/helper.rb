# frozen_string_literal: true

module MiqFlow
  # Helper Methods, that do not fit anywhere else
  module Cli
    def cli_setup(options={}, mode=[])
      MiqFlow::Config.process_cli_flags(options) # Set log level first
      MiqFlow::Config.search_config_files()
      MiqFlow::Config.process_environment_variables()
      MiqFlow::Config.process_config_file(options['config'])
      MiqFlow::Config.process_cli_flags(options) # And again for precedence

      MiqFlow.validate(mode)
      MiqFlow.init()
      MiqFlow.prepare_repo()
    end

    def get_diff_data(feature, api)
      data = {}
      feature.miq_domain.each do |domain|
        $logger.debug("Searching AeMethods in #{domain.name}")
        # Get base data from MaangeIQ
        api_data = api.find_ae_methods(domain.name, columns: %i[name data location])
        # Add some static data
        api_data.each do |method|
          data[method[:fqname].to_sym] = method.merge(
            domain.file_data(
              git_workdir: feature.git_workdir,
              namespace: method[:namespace],
              klass: method[:class],
              name: method[:name]
            )
          )
        end
      end
      data
    end
  end
end
