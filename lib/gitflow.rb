# Global Methods
module GitFlow
  include GitFlow::Settings
  include GitMethods
  include ApiMethods
  Error = Class.new(StandardError)

  def self.init
    $logger.debug("Using Settings: #{$settings.to_yaml}")

    # prepare directories
    #
    $tmpdir = $settings[:workdir] == 'auto' ? Dir.mktmpdir('miq_import_') : $settings[:workdir]
    Dir.mkdir(File.join($tmpdir, 'repo'))
    Dir.mkdir(File.join($tmpdir, 'import'))
    $logger.debug("Using tmp directory: #{$tmpdir}")
  end

  def self.prepare_repo
    opts = $settings[:git]
    GitMethods.clone_repo(opts) unless opts[:url].nil?
    GitMethods.local_repo(opts) unless opts[:path].nil?
  end

  def self.tear_down
    return unless $settings[:clear_tmp]

    FileUtils.rm_rf(File.join($tmpdir, 'import'))
    FileUtils.rm_rf(File.join($tmpdir, 'repo'))
    FileUtils.rmdir($tmpdir) if Dir["#{$tmpdir}/*"].empty?
  end

  def self.validate
    if $settings[:git][:url].nil? && $settings[:git][:path].nil?
      $logger.fatal('No git repository specified')
      valid = false
    end
    valid != false
  end
end
