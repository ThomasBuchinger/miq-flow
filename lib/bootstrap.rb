require 'rugged'
require 'tmpdir'
require 'logger'

lib_dir = __dir__
$LOAD_PATH << lib_dir
require 'feature.rb'
require 'gitflow.rb'
require 'miq/provider_docker.rb'
require 'miq/provider_local.rb'
require 'miq/provider_noop.rb'

$default_opts = { :clear_tmp => true }
$default_opts[:feature_defaults] = {:miq_fs_domain=>'foo', :miq_provider=>GitFlow::MiqProvider::Noop.new()}
$default_opts[:git_opts] = {}
GitFlow.process_environment_variables()
require_relative '../custom.rb' if File.file?(File.expand_path(File.join(lib_dir, '..', 'custom.rb')))
$default_opts.freeze()
GitFlow.validate()
