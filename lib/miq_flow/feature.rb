# frozen_string_literal: true

require 'pathname'
require_relative 'domain.rb'

module MiqFlow
  # A feature the top level object representing a feature-branch.
  # It includes aspects of handling git branches as well as ManageIQ Automate domains
  #
  class Feature
    include MiqFlow::GitMethods
    include MiqFlow::MiqMethods::MiqUtils

    attr_accessor :git_branch, :git_master
    attr_accessor :miq_domain
    attr_reader   :git_repo, :git_workdir

    # Sets up a bunch of instance variables
    #
    # @option opts [String] :remote_name('origin')
    # @option opts [String] :base('master')
    # @option opts [Array<String>]        :prefix(feature, fix)
    def _set_defaults(opts={})
      @remote_name = opts.fetch(:remote_name, 'origin')
      @base        = opts.fetch(:base,        'master')
      # unused
      @prefixes    = opts.fetch(:prefix,      [''])
    end

    # Represents a feature-branch
    #
    # @param [String] branch_name
    # @option opts @see _set_defaults
    def initialize(branch_name, opts={})
      _set_defaults(opts)
      @name = opts.fetch(:feature_name, nil) || name_from_branch(branch_name)
      $logger.debug("Creating Feature: branch=#{branch_name} domain=#{@name}")

      @git_repo = opts.fetch(:git_repo, nil) || $git_repo
      raise MiqFlow::GitError, 'Unable to find git repo' if @git_repo.nil?()

      _create_git(branch_name, @git_repo)

      method       = opts.fetch(:miq_import_method, 'partial')
      provider     = opts.fetch(:provider,          'default')
      @git_workdir = @git_repo.workdir()
      @miq_domain  = discover_domains(provider: provider, miq_import_method: method)
    end

    def checkout
      @git_repo.checkout(@git_branch)
    end

    # Deploys the feature to ManageIQ
    # This will deploy a new Automate Domain for every Domain found on the file system, with at
    # least one changed file
    #
    def deploy
      checkout
      paths = get_diff_paths()
      deploy_opts = { changeset: paths, git_workdir: @git_workdir }
      # The import does not honor the priority setting in the domain => import from lowest to highest priority
      @miq_domain.sort!{ |dom1, dom2| dom1.miq_priority <=> dom2.miq_priority }
      @miq_domain.each do |domain|
        $logger.info("Deploying: #{domain.name}")
        $logger.debug("  Directory: #{domain.export_dir}/#{domain.export_name}")
        $logger.debug("  Priority: #{domain.miq_priority}")
        domain.deploy(deploy_opts.dup)
      end
    end

    # Searches for Automate Domain exports on the file system
    #
    def discover_domains(opts={})
      feature_level_params = {}
      feature_level_params[:feature_name] = @name
      feature_level_params[:branch_name]  = @git_branch.name
      feature_level_params[:provider]     = opts[:provider]
      feature_level_params[:miq_import_method] = opts[:miq_import_method]
      domains = find_domain_files(@git_repo.workdir)
      domains.map{ |dom| MiqFlow::MiqDomain.create_from_file(dom.merge(feature_level_params)) }
    end

    def details
      paths = get_diff_paths()
      {
        name: @name,
        branch_name: @git_branch.name,
        base_sha: @git_base.tree_id,
        base_message: @git_base.summary,
        branch_sha: @git_branch.target.tree_id,
        branch_message: @git_branch.target.summary,
        domain: @miq_domain.map{ |dom| dom.details(paths) }
      }
    end
  end
end
