require 'logger'

$LOAD_PATH << File.dirname(__FILE__)
require 'lib/feature.rb'
require 'lib/miq/provider_docker.rb'
require 'lib/miq/provider_local.rb'
require 'lib/utils.rb'

$logger  = Logger.new(STDOUT)
$logger.level = Logger::DEBUG
BRANCHES = { 'master'=>{'miq_domain'=> 'buc'} }


$git_repo = Rugged::Repository.new('../automate-example')

#GitOps::Core._set_defaults()
#GitOps::Core._sync_branches(handle)
#f1 = GitFlow::Core.new('feature-1-f1', miq_domain: 'buc')
#f1.deploy()
#f2 = GitFlow::Core.new('feature-2-f2', miq_domain: 'f2')
#f2.deploy()
