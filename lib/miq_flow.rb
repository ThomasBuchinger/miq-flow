# frozen_string_literal: true

require 'rugged'
require 'tmpdir'
require 'logger'
require 'yaml'
require 'time'

lib_dir = __dir__
$LOAD_PATH << lib_dir
require 'miq_flow/pluggable/provider_docker'
require 'miq_flow/pluggable/provider_local'
require 'miq_flow/pluggable/provider_noop'
require 'miq_flow/pluggable/method_partial'
require 'miq_flow/pluggable/method_clean'
require 'miq_flow/error'
require 'miq_flow/mixin_miq'
require 'miq_flow/mixin_git'
require 'miq_flow/mixin_api'
require 'miq_flow/mixin_settings'
require 'miq_flow/manageiq'
require 'miq_flow/domain'
require 'miq_flow/feature'
require 'miq_flow/miqflow'
require 'miq_flow/cli'
require 'miq_flow/version'

$settings = {}
$settings[:miq] = {}
$settings[:git] = {}
MiqFlow::Settings.set_defaults()
