# Global Methods
module GitFlow
  Error = Class.new(StandardError)

  def self.init
    # configure logging
    #
    $logger = Logger.new(STDOUT)
    $logger.level = $default_opts.fetch(:log_level, Logger::INFO)

    # prepare directories
    #
    $tmpdir = Dir.mktmpdir('miq_import_')
    Dir.mkdir(File.join($tmpdir, 'repo'))
    Dir.mkdir(File.join($tmpdir, 'import'))
    $logger.debug("Using tmp directory: #{$tmpdir}")

    # get git repository
    #
    prepare_repo($default_opts[:git_opts])
  end

  def self.tear_down
    FileUtils.rm_rf($tmpdir) if $default_opts[:clear_tmp] == true
  end

  def self.validate
    if $git_url.nil? && $git_path.nil?
      STDERR.puts('No git repository specified')
      valid = false
    end
    valid != false
  end

  def self.process_environment_variables
    # Git params
    $git_url      = ENV['GIT_URL']      || $git_url
    $git_user     = ENV['GIT_USER']     || $git_user
    $git_password = ENV['GIT_PASSWORD'] || $git_password
    $git_path     = ENV['GIT_PATH']     || $git_path

    # MIQ params

    # Misc
    $default_opts[:log_level] = Logger::DEBUG if ENV['VERBOSE'] == 'true'
    $default_opts[:log_level] = Logger::WARN if ENV['QUIET'] == 'true'
    $default_opts[:clear_tmp] = false if ENV['CLEAR_TMP'] == 'false'
    puts $default_opts
  end

  def self.prepare_repo(opts)
    clone_repo(opts) unless $git_url.nil?
    local_repo(opts) unless $git_path.nil?
  end

  def self.clone_repo(opts)
    $logger.info("Cloning git Repository from: #{$git_url}")
    dir = File.join($tmpdir, 'repo')

    # make Credentials
    if $git_user && $git_password
      cred = Rugged::Credentials::UserPassword.new(username: $git_user, password: $git_password)
      opts[:credentials] = cred
    end

    begin
      $git_repo = Rugged::Repository.clone_at($git_url, dir, opts)
    rescue Rugged::NetworkError
      raise GitFlow::Error, "Failed to clone repository at #{$git_url}: #{e}"
    rescue Rugged::RepositoryError
      raise GitFlow::Error, "Failed to clone repository at #{$git_url}: #{e}"
    end
  end

  def self.local_repo(opts)
    $logger.info("Using git Repository: #{$git_path}")
    begin
      $git_repo = Rugged::Repository.discover($git_path, opts.fetch(:accross_fs, true))
    rescue Rugged::RepositoryError
      raise GitFlow::Error, "Failed to find a repository at #{$git_path}" if $git_repo.nil?
    end
  end
end
