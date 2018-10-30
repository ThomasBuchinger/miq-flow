module GitFlow
  class Error < StandardError; end  

  def self.init()
    # prepare directories
    #
    $tmpdir = Dir.mktmpdir('miq_import_')
    Dir.mkdir(File.join($tmpdir, 'repo'))
    Dir.mkdir(File.join($tmpdir, 'import'))

    # configure logging
    #
    $logger  = Logger.new(STDOUT)
    $logger.level = $default_opts.fetch(:log_level, Logger::INFO)

    # get git repository
    #
    prepare_repo($default_opts[:git_opts])
  end
  def self.tear_down()
    FileUtils::rm_rf($tmpdir) if $default_opts[:clear_tmp] == true
  end
  def self.validate()
    if $git_url.nil? and $git_path.nil?
      STDERR.puts("No git repository specified")
      valid = false
    end
    valid != false
  end

  

  def self.process_environment_variables()
    # Git params
    $git_url      = ENV['GIT_URL']      || $git_url
    $git_user     = ENV['GIT_USER']     || $git_user
    $git_password = ENV['GIT_PASSWORD'] || $git_password
    $git_path     = ENV['GIT_PATH']     || $git_path

    # MIQ params
    $default_opts[:feature_defaults][:miq_fs_domain] = ENV['EXPORT_NAME'] || ENV['MIQ_FS_DOMAIN'] || $export_name

    # Misc
    $default_opts[:log_level] = Logger::DEBUG if ENV['VERBOSE'] == 'true' 
    $default_opts[:log_level] = Logger::WARN  if ENV['QUIET'] == 'true'
    $default_opts[:clear_tmp] = false  if ENV['CLEAR_TMP'] == 'false'
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
    opts[:credentials] = Rugged::Credentials::UserPassword.new(username: $git_user, password: $git_pssword) if $git_user and $git_password

    begin 
      $git_repo = Rugged::Repository.clone_at($git_url, dir, opts)
    rescue Rugged::NetworkError => e
      raise GitFlow::Error, "Failed to clone repository at #{$git_url}: #{e}"
    rescue Rugged::RepositoryError => e
      raise GitFlow::Error, "Failed to clone repository at #{$git_url}: #{e}"
    end
  end
  def self.local_repo(opts)
    $logger.info("Using git Repository: #{$git_path}")
    begin
      $git_repo = Rugged::Repository.discover($git_path, opts.fetch(:accross_fs, true))
    rescue Rugged::RepositoryError => e
      raise GitFlow::Error, "Failed to find a repository at #{$git_path}" if $git_repo.nil?
    end
  end
end
