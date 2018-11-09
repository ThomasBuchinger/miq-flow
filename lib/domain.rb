module GitFlow
  class MiqDomain
    include GitFlow::MiqMethods
    attr_accessor :name, :miq_provider
    attr_accessor :import_method, :export_dir, :export_name

    # Sets up a bunch of instance variables 
    #
    # @option opts [GitFlow::MiqProvider] :provider(GitFlow::MiqProvider::Noop)
    # @option opts [String] :automate_dir('automate')
    # @option opts [String] :miq_priority(10)
    # @option opts [String] :miq_fs_domain(nil)
    def _set_defaults(opts={})
      @miq_provider      = opts.fetch(:provider,          nil )
      @automate_dir      = opts.fetch(:automate_dir,      'automate' )
      @miq_prioritiy     = opts.fetch(:miq_priority,      10 )
      @miq_fs_domain     = opts.fetch(:miq_fs_domain,     nil )
      @miq_import_method = opts.fetch(:miq_import_method, :partial)
    end


    
    # Represents a feature-branch
    #
    # @param [String] branch_name 
    # @option opts @see _set_defaults
    def initialize(name, opts)
      _set_defaults(opts)
      _create_miq(name)
    end

    def _create_miq(domain_name)
      @name    = domain_name
      @miq_fs_domain = @miq_fs_domain || domain_name
      @miq_provider  = @miq_provider || GitFlow::MiqProvider::Noop.new
    end



    def prepare_import(method, feature)
      self.send("prepare_import_#{method}".to_sym, feature)
    end
    def cleanup_import(method)
      self.send("cleanup_import_#{method}".to_sym)
    end

    def deploy()
      import_dir = prepare_import(@miq_import_method, @miq_domain)
      @miq_provider.import(File.join(import_dir, @automate_dir), @miq_fs_domain, @miq_domain)
      cleanup_import(@miq_import_method)
    end

  end
end
