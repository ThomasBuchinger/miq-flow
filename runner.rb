require 'logger'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/feature.rb'
require 'lib/miq/provider_docker.rb'
require 'lib/miq/provider_local.rb'
require 'lib/utils.rb'

$logger  = Logger.new(STDOUT)
$logger.level = Logger::DEBUG
BRANCHES = { 'master'=>{'miq_domain'=> 'buc'} }

# $git_repo needs to be specified in custom.rb
#$git_repo = Rugged::Repository.new('../automate-example')

