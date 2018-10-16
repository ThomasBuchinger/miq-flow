require_relative 'git/mixin_git.rb'
require_relative 'miq/mixin_miq.rb'

module GitFlow
  class Core
    include GitFlow::GitMethods
    include GitFlow::MiqMethods

    attr_accessor :git_branch, :git_master
    attr_accessor :miq_domain
    attr_reader   :git_repo

    def _set_defaults(opts={})
      @remote_name  = opts.fetch(:remote_name, 'origin')
      @master       = opts.fetch(:master, 'master')
      @prefixes     = opts.fetch(:prefix, ['feature', 'fix'] )
      @miq_provider = opts.fetch(:provider, GitFlow::MiqProvider::Docker.new )
      @automate_dir = opts.fetch(:automate_dir, 'automate' )
    end

    def _create_git(branch_name, repo)

      @git_master = repo.branches[@master]
      @git_branch = repo.branches["#{@remote_name}/#{branch_name}"]

      raise "Unable to find base branch: #{@master}"        if @git_master.nil?()
      raise "Unable to find feature branch: #{branch_name}" if @git_branch.nil?()
    end

    def _create_miq(domain_name)
      @miq_domain = domain_name
      @miq_import_method = :dirty
    end
    
    def initialize(branch_name, opts)
      miq_domain = opts.fetch(:miq_domain, branch_name.split(/-/)[2]) || branch_name
      @git_repo   = opts.fetch(:git_repo, nil) || $git_repo
      _set_defaults(opts)
      $logger.debug("Creating Core: branch=#{branch_name} domain=#{miq_domain}")

      raise 'Unable to find git repo' if @git_repo.nil?()
      _create_git(branch_name, @git_repo)
      _create_miq(miq_domain)
    end

    def deploy()
      @git_repo.checkout(@git_branch)
      $logger.debug("Deploying: #{@miq_domain}") 

      tmpdir = prepare_import(@miq_import_method, @miq_domain)
      @miq_provider.import(tmpdir, @miq_domain)
      cleanup_import(@miq_import_method)
      
    end

  end
end

