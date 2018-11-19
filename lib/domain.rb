module GitFlow
  class MiqDomain
    include GitFlow::MiqMethods
    # Mandatory parameters
    attr_accessor :name
    # Mandatory parameters with guessable defaults
    attr_accessor :miq_provider, :import_method, :export_dir, :export_name

    # Optional Parameters
    attr_accessor :miq_priority
    attr_reader :changeset, :branch_name

    # Sets up a bunch of instance variables 
    #
    def _set_defaults(opts={})
      @miq_provider_name = opts.fetch(:miq_provider,      'noop')
      @export_dir        = opts.fetch(:export_dir,        nil )
      #@export_dir        = opts.fetch(:export_dir,        'automate' )
      @export_name       = opts.fetch(:export_name,       @name )
      @miq_import_method = opts.fetch(:miq_import_method, :partial)
      @miq_priority      = opts.fetch(:miq_priority,      10 )
      @miq_priority      = opts.fetch(:miq_priority,      10 )
      @branch_name       = opts.fetch(:branch_name,       'No Branch' )
    end

    def _limit_changeset(files)
      @changeset = files.select {|f| f.include?(@export_name)}
    end

    def self.create_from_file(dom)
      opts = {}
      opts[:export_name]   = dom[:domain_name]
      opts[:export_dir]    = dom[:relative_path]
      opts[:import_method] = dom[:import_method] 
      new_name  = "feature_#{dom[:feature_name]}_#{opts[:export_name]}"
      opts[:provider_name] = dom[:provider]
      
      opts.select!{|_, value| !value.nil? }
      self.new(new_name, opts)
    end
    
    def self.create_from_config(name, opts)
      self.new(name, opts)
    end

    # Represents a feature-branch
    #
    # @param [String] branch_name 
    # @option opts @see _set_defaults
    def initialize(name, opts)
      @name = name
      _set_defaults(opts)

      @miq_provider = GitFlow::MiqProvider::Noop.new      if opts[:provider_name] == 'noop'
      @miq_provider = GitFlow::MiqProvider::Appliance.new if opts[:provider_name] == 'local'
      @miq_provider = GitFlow::MiqProvider::Docker.new    if opts[:provider_name] == 'docker'
      @miq_provider = GitFlow::MiqProvider::Noop.new      if @miq_provider.nil?
    end

    def prepare_import(domain_data, feature_data)
      self.send("prepare_import_#{@miq_import_method}".to_sym, domain_data, feature_data)
    end
    def cleanup_import(prep_data)
      self.send("cleanup_import_#{@miq_import_method}".to_sym)
    end

    def deploy(opts)
      opts[:changeset] = _limit_changeset(opts.fetch(:changeset, []))
      if opts[:skip_empty] and opts[:changeset].empty?()
        $logger.info("Skipping Domain: #{@name}: empty")
        return true
      end
      $logger.error("Deploy in Domain: #{self.instance_variables.map{|v| "#{v}=#{self.instance_variable_get(v)}" }}")

      prep_data = prepare_import(self, opts)
      @miq_provider.import(File.join(prep_data[:import_dir], @export_dir), @export_name, @name)
      cleanup_import(prep_data)
    end

  end
end
