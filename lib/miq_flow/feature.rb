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

    # Deploys the feature to ManageIQ
    # This will deploy a new Automate Domain for every Domain found on the file system, with at
    # least one changed file
    #
    def deploy
      @git_repo.checkout(@git_branch)
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

    def show_details
      commit = @git_base
      paths  = get_diff_paths()
      ret = []
      ret << "Feature: #{@name} on branch #{@git_branch.name} "
      ret << " Branch: #{@git_branch.target.tree_id}: #{@git_branch.target.summary}"
      ret << "   Base: #{commit.tree_id}: #{commit.summary}"
      ret << ''
      @miq_domain.each do |dom|
        ret << dom.name
        dom._limit_changeset(paths).each{ |path| ret << "  #{path}" }
      end
      ret.join("\n")
    end

    def show_summary
      paths = get_diff_paths()
      domain_info   = @miq_domain.map{ |dom| { name: dom.name, change_num: dom._limit_changeset(paths).length } }
      domain_string = domain_info.map{ |d| "#{d[:name]}: #{d[:change_num]}" }.join(' ')
      "#{@git_branch.name}: #{domain_string}"
    end
  end
end
