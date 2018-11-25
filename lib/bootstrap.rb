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
require 'mixin_settings.rb'
require 'domain.rb'
require 'feature.rb'
require 'gitflow.rb'

$settings = {}
$settings[:miq] = {}
$settings[:git] = {}
GitFlow::Settings.set_defaults()
['config.yml', 'config.yaml'].each do |file|
  GitFlow::Settings.process_config_file(file)
end
GitFlow::Settings.process_environment_variables()
$settings.freeze()
GitFlow.validate() ? true : exit(1)
