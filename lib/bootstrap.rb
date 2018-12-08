require 'rugged'
require 'tmpdir'
require 'logger'
require 'yaml'

lib_dir = __dir__
$LOAD_PATH << lib_dir
require 'miq/provider_docker.rb'
require 'miq/provider_local.rb'
require 'miq/provider_noop.rb'
require 'miq/method_partial.rb'
require 'miq/method_clean.rb'
require 'miq/mixin_miq.rb'
require 'mixin_git.rb'
require 'mixin_api.rb'
require 'mixin_settings.rb'
require 'domain.rb'
require 'feature.rb'
require 'gitflow.rb'

$settings = {}
$settings[:miq] = {}
$settings[:git] = {}
GitFlow::Settings.set_defaults()
SEARCHPATH = [
  'config.yml',
  'config.yaml',
  'gitflow.yml',
  'gitflow.yaml',
  File.expand_path('~/.gitflow.yml'),
  File.expand_path('~/.gitflow.yaml'),
  File.expand_path('~/.gitflow/config.yml'),
  File.expand_path('~/.gitflow/config.yaml')
].freeze
SEARCHPATH.each do |file|
  GitFlow::Settings.process_config_file(file)
end
GitFlow::Settings.process_environment_variables()
GitFlow.validate() ? true : exit(1)
