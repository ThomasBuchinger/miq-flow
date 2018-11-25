# Global Methods
module GitFlow
  include GitFlow::Settings
  Error = Class.new(StandardError)

  def self.init
    $logger.debug("Using Settings: #{$settings.to_yaml}")

    # prepare directories
    #
    $tmpdir = $settings[:workdir] == 'auto' ? Dir.mktmpdir('miq_import_') : $settings[:workdir]
    Dir.mkdir(File.join($tmpdir, 'repo'))
    Dir.mkdir(File.join($tmpdir, 'import'))
    $logger.debug("Using tmp directory: #{$tmpdir}")

    # get git repository
    #
    prepare_repo($settings[:git])
  end

  def self.tear_down
    FileUtils.rm_rf($tmpdir) if $settings[:clear_tmp]
  end

  def self.validate
    if $settings[:git][:url].nil? && $settings[:git][:path].nil?
      $logger.fatal('No git repository specified')
      valid = false
    end
    valid != false
  end

  def self.prepare_repo(opts)
    clone_repo(opts) unless $settings[:git][:url].nil?
    local_repo(opts) unless $settings[:git][:path].nil?
  end

  def self.clone_repo(opts)
    url = $settings[:git][:url]
    $logger.info("Cloning git Repository from: #{url}")
    user = $settings[:git][:user]
    pass = $settings[:git][:password]
    dir  = File.join($tmpdir, 'repo')

    # make Credentials
    opts[:credentials] = Rugged::Credentials::UserPassword.new(username: user, password: pass) if user && pass

    $git_repo = Rugged::Repository.clone_at(url, dir, opts)
  rescue Rugged::NetworkError
    raise GitFlow::Error, "Failed to clone repository at #{url}: #{e}"
  rescue Rugged::RepositoryError
    raise GitFlow::Error, "Failed to clone repository at #{url}: #{e}"
  end

  def self.local_repo(opts)
    path = $settings[:git][:path]
    $logger.info("Using git Repository: #{path}")
    $git_repo = Rugged::Repository.discover(path, opts.fetch(:accross_fs, true))
  rescue Rugged::RepositoryError
    raise GitFlow::Error, "Failed to find a repository at #{path}" if $git_repo.nil?
  end
end
