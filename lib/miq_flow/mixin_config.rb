# frozen_string_literal: true

module MiqFlow
  # This mixin handles processing of different
  # configuration sources (env, file, cli)
  module Config
    extend Settings

    def self.search_config_files
      $settings[:searchpath].each do |file|
        process_config_file(file)
      end
    end

    def self.process_environment_variables
      # Git params
      update_git(ENV['GIT_URL'], ENV['GIT_PATH'], ENV['GIT_USER'], ENV['GIT_PASSWORD'])

      # MIQ params
      update_miq_api(ENV['MIQ_URL'], ENV['MIQ_USER'], ENV['MIQ_PASSWORD'])

      # Misc
      update_log_level_with_flags(verbose: ENV['verbose'], quiet: ENV['quiet'], silent: ENV['silent'])
      update_clear_tmp(ENV['CLEAR_TMP'])
      update_workdir(ENV['WORKDIR'])
    end

    def self.process_cli_flags(options={})
      update_log_level_with_flags(verbose: options['verbose'], quiet: options['quiet'], silent: options['silent'])
      update_clear_tmp(options['cleanup'])
      update_workdir(options['workdir'])

      update_git(options['git_url'], options['git_path'], options['git_user'], options['git_password'])
      update_miq_api(options['miq_url'], options['miq_user'], options['miq_password'])
    end

    def self.process_config_file(path) # rubocop:disable Metrics/AbcSize
      return unless path.kind_of?(String) && File.file?(path)

      $logger.info("Processing config file: #{path}")
      conf = YAML.load_file(path) || {}
      git_conf = conf['git'] || {}
      miq_conf = conf['miq'] || {}

      update_log_level(conf['log_level'])
      update_clear_tmp(conf['clear_tmp'])
      update_git(git_conf['url'], git_conf['path'], git_conf['user'], git_conf['password'])
      update_miq_api(miq_conf['url'], miq_conf['user'], miq_conf['password'])
      update_workdir(conf['workdir'])
    end
  end
end
