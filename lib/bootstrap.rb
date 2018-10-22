require 'rugged'
require 'tmpdir'
require 'logger'

$LOAD_PATH << File.dirname(__FILE__)
require 'feature.rb'
require 'miq/provider_docker.rb'
require 'miq/provider_local.rb'
require 'miq/provider_noop.rb'

$default_opts = { :clear_tmp => true }
$default_opts[:feature_defaults] = {:miq_fs_domain=>'foo', :miq_provider=>GitFlow::MiqProvider::Noop.new()}
$default_opts[:git_opts] = {}

require_relative '../custom.rb'
$default_opts.freeze()


module GitFlow
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
    FileUtils::rm_rf($tmpdir)
  end

  def self.prepare_repo(opts)   
    clone_repo(opts) unless $git_url.nil?
    local_repo(opts) unless $git_path.nil?
  end
  def self.clone_repo(opts)
    $logger.info("Cloning git Repository from: #{$git_url}")
    dir = File.join($tmpdir, 'repo')
    $git_repo = Rugged::Repository.clone_at($git_url, dir, opts)
    raise "Failed to clone repository at #{$git_url}" if $git_repo.nil?
  end
  def self.local_repo(opts)
    $logger.info("Using git Repository: #{$git_path}")
    $git_repo = Rugged::Repository.discover($git_path, opts.fetch(:accross_fs, true))
    raise "Failed to clone repository at #{$git_path}" if $git_repo.nil?
  end
end
