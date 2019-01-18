# frozen_string_literal: true

require 'rugged'
require 'tmpdir'
require 'logger'
require 'yaml'
require 'time'

lib_dir = __dir__
$LOAD_PATH << lib_dir
require 'miq/provider_docker.rb'
require 'miq/provider_local.rb'
require 'miq/provider_noop.rb'
require 'miq/method_partial.rb'
require 'miq/method_clean.rb'
require 'mixin_miq.rb'
require 'mixin_git.rb'
require 'mixin_api.rb'
require 'error.rb'
require 'mixin_settings.rb'
require 'cli/cli.rb'
require 'manageiq.rb'
require 'domain.rb'
require 'feature.rb'
require 'gitflow.rb'

$settings = {}
$settings[:miq] = {}
$settings[:git] = {}
GitFlow::Settings.set_defaults()
