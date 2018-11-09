require_relative 'git/mixin_git.rb'
require_relative 'domain.rb'

module GitFlow
  # A feature the top level object representing a feature-branch.
  # It includes aspects of handling git branches as well as ManageIQ Automate domains
  #
  class Feature
    include GitFlow::GitMethods

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
      @remote_name       = opts.fetch(:remote_name,       'origin')
      @base              = opts.fetch(:base,              'master')
      @prefixes          = opts.fetch(:prefix,            ['feature', 'fix'] )
    end


    
    # Represents a feature-branch
    #
    # @param [String] branch_name 
    # @option opts @see _set_defaults
    def initialize(branch_name, opts={})
      domain_name = opts.fetch(:miq_domain, branch_name.split(/-/)[2]) || branch_name
      @git_repo  = opts.fetch(:git_repo, nil) || $git_repo
      _set_defaults(opts)
      $logger.debug("Creating Feature: branch=#{branch_name} domain=#{domain_name}")

      raise GitFlow::Error, 'Unable to find git repo' if @git_repo.nil?()
      _create_git(branch_name, @git_repo)

      @miq_domain = [ GitFlow::MiqDomain.new(domain_name, opts) ]
    end

    # Deploys the feature to ManageIQ
    #
    def deploy()
      @git_repo.checkout(@git_branch)
      @miq_domain.each do |domain|
        $logger.info("Deploying: #{domain.name}")
        domain.deploy()
      end 

    end

  end
end

