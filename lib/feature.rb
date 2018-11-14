require 'pathname'
require_relative 'git/mixin_git.rb'
require_relative 'domain.rb'

module GitFlow
  # A feature the top level object representing a feature-branch.
  # It includes aspects of handling git branches as well as ManageIQ Automate domains
  #
  class Feature
    include GitFlow::GitMethods
    include GitFlow::MiqMethods::MiqUtils

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
      @provider          = opts.fetch(:provider,          'default')
    end


    
    # Represents a feature-branch
    #
    # @param [String] branch_name 
    # @option opts @see _set_defaults
    def initialize(branch_name, opts={})
      _set_defaults(opts)
      @name = opts.fetch(:feature_name, branch_name.split(/-/)[2]) || branch_name
      $logger.debug("Creating Feature: branch=#{branch_name} domain=#{@name}")

      @git_repo  = opts.fetch(:git_repo, nil) || $git_repo
      raise GitFlow::Error, 'Unable to find git repo' if @git_repo.nil?()
      _create_git(branch_name, @git_repo)

      @miq_domain  = discover_domains()
    end

    # Deploys the feature to ManageIQ
    #
    def deploy()
      @git_repo.checkout(@git_branch)
      deploy_opts = {:changeset=>get_diff_paths(), :git_workdir=>@git_repo.workdir}
      @miq_domain.each do |domain|
        $logger.info("Deploying: #{domain.name}")
        domain.deploy(deploy_opts)
      end 

    end

    # Finds all Domains in the Repository
    #
    def discover_domains()
      feature_level_params = {:feature_name=>@name, :branch_name => @git_branch.name, :provider=>@provider}
      domains = find_domain_files(@git_repo.workdir)
      domains.map{|dom| GitFlow::MiqDomain.create_from_file(dom.merge(feature_level_params))}
    end

    def show()
      commit = merge_base(@git_repo, @git_branch.name)
      paths  = get_diff_paths()
      ret = []
      ret << "Feature: #{@name} on branch #{@git_branch.name} "
      ret << " Branch: #{@git_branch.target.tree_id}: #{@git_branch.target.summary}"
      ret << "   Base: #{commit.tree_id}: #{commit.summary}"
      ret << ""
      @miq_domain.each do|dom|
        ret << dom.name
        dom._limit_changeset(paths).each{|path| ret << "  #{path}" }
      end
      return ret.join("\n")
    end

  end
end
