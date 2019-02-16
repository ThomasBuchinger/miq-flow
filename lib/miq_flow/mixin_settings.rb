# frozen_string_literal: true

module MiqFlow
  # This mixin handles configuration updates
  # Every update_* method only modifies he config if a
  # reasonable value is provided
  module Settings
    SEARCHPATH = [
      '/etc/miqflow.yml',
      '/etc/miqflow.yaml',
      File.expand_path('~/.miqflow.yml'),
      File.expand_path('~/.miqflow.yaml'),
      File.expand_path('~/.miqflow/config.yml'),
      File.expand_path('~/.miqflow/config.yaml')
    ].freeze

    def set_defaults
      update_searchpath(SEARCHPATH.dup, replace: true)
      update_log_level(:info)
      update_clear_tmp('yes')
      update_workdir('auto')

      update_miq_api(nil, 'admin', nil)
      update_naming(['-', '/'], 1)
    end

    def update_searchpath(path=[], replace: false)
      return $settings[:searchpath] = path if replace

      $settings[:searchpath] = path.concat($settings[:searchpath])
    end

    def update_log_level_with_flags(verbose: 'no', quiet: 'no', silent: 'no')
      update_log_level(:debug)  if truthy(verbose)
      update_log_level(:warn)   if truthy(quiet)
      update_log_level(:no_log) if truthy(silent)
    end

    def update_log_level(level)
      return if level.nil?

      log_level = {
        debug: Logger::DEBUG,
        info: Logger::INFO,
        warn: Logger::WARN,
        error: Logger::ERROR,
        fatal: Logger::FATAL,
        no_log: Logger::UNKNOWN
      }
      return unless log_level.key?(level.to_sym)

      # Create logger if nit already creates
      $logger = Logger.new(STDERR) if $logger.nil?
      $logger.level = log_level[level.to_sym]

      # This is just for documentation, when dumping the config
      $settings[:log_level] = level
    end

    def update_clear_tmp(clear_flag)
      return unless truthy(clear_flag) || falsey(clear_flag)

      $settings[:clear_tmp] = truthy(clear_flag)
    end

    def update_git(url, path, user, password)
      $settings[:git][:url]  = url  unless url.nil?
      $settings[:git][:path] = path unless path.nil?
      $settings[:git][:user] = user unless user.nil?
      $settings[:git][:password] = password unless password.nil?
    end

    def update_naming(separators, index)
      $settings[:naming_separator] = separators unless separators.nil? || separators.empty?
      $settings[:naming_index] = index.to_i unless index.nil? || !index.respond_to?(:to_i)
    end

    def update_workdir(dir)
      return if dir.nil?

      return if dir != 'auto' && !File.directory?(dir)

      $settings[:workdir] = dir
    end

    def update_miq_api(url, user, password)
      $settings[:miq][:url]      = url unless url.nil?
      $settings[:miq][:user]     = user unless user.nil?
      $settings[:miq][:password] = password unless password.nil?
    end

    def truthy(value)
      true_values = %w[true TRUE True yes YES Yes t T y Y 1]
      true_values.include?(value.to_s)
    end

    def falsey(value)
      false_values = %w[false FALSE False no NO No f F n N 0]
      false_values.include?(value.to_s)
    end
  end
end
