require_relative 'git/mixin_git.rb'
require_relative 'miq/mixin_miq.rb'

module GitFlow
  # A feature the top level object representing a feature-branch.
  # It includes aspects of handling git branches as well as ManageIQ Automate domains
  #
  class Feature
    include GitFlow::GitMethods
    include GitFlow::MiqMethods

    attr_accessor :git_branch, :git_master
    attr_accessor :miq_domain
    attr_reader   :git_repo

    # Sets up a bunch of instance variables 
    #
    # @option opts [String] :remote_name('origin')
    # @option opts [String] :base('master')
    # @option opts [Array<String>]        :prefix(feature, fix)
    # @option opts [GitFlow::MiqProvider] :provider(GitFlow::MiqProvider::Noop)
    # @option opts [String] :automate_dir('automate')
    # @option opts [String] :miq_priority(10)
    # @option opts [String] :miq_fs_domain(nil)
    def _set_defaults(opts={})
      @remote_name   = opts.fetch(:remote_name,   'origin')
      @base          = opts.fetch(:base,          'master')
      @prefixes      = opts.fetch(:prefix,        ['feature', 'fix'] )
      @miq_provider  = opts.fetch(:provider,      GitFlow::MiqProvider::Noop.new )
      @automate_dir  = opts.fetch(:automate_dir,  'automate' )
      @miq_prioritiy = opts.fetch(:miq_priority,  10 )
      @miq_fs_domain = opts.fetch(:miq_fs_domain, nil )
    end


    def _create_miq(domain_name)
      @miq_domain    = domain_name
      @miq_fs_domain = @miq_fs_domain || domain_name
      @miq_import_method = :dirty
    end
    
    # Represents a feature-branch
    #
    # @param [String] branch_name 
    # @option opts @see _set_defaults
    def initialize(branch_name, opts={}) 
      miq_domain = opts.fetch(:miq_domain, branch_name.split(/-/)[2]) || branch_name
      @git_repo  = opts.fetch(:git_repo, nil) || $git_repo
      _set_defaults(opts)
      $logger.debug("Creating Feature: branch=#{branch_name} domain=#{miq_domain}")

      raise 'Unable to find git repo' if @git_repo.nil?()
      _create_git(branch_name, @git_repo)
      _create_miq(miq_domain)
    end

    # Deploys the feature to ManageIQ
    #
    def deploy()
      @git_repo.checkout(@git_branch)
      $logger.debug("Deploying: #{@miq_domain}") 

      tmpdir = prepare_import(@miq_import_method, @miq_domain)
      @miq_provider.imuport(tmpdir, @miq_fs_domain, @miq_domain)
      cleanup_import(@miq_import_method)
      
    end

  end
end

