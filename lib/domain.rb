module GitFlow
  # Represents a single ManageIQ Automate Domain on disk
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
    # @option opts [String] :miq_provider(noop) CHOICE: noop, local, docker
    # @option opts [String] :export_dir relative path to the domain export from git working dir
    # @option opts [String] :miq_import_method(partial) CHOICE partial, clean
    #                       partial: imports only changed files
    #                       clean: imports everything
    # @option opts [String] :miq_priority DOES NOTHING, since the importer does not honor it
    # @option opts [String] :branch_name name of the git branch. INFO only
    def _set_defaults(opts = {})
      @miq_provider_name = opts.fetch(:miq_provider,      'noop')
      @export_dir        = opts.fetch(:export_dir,        'automate')
      @export_name       = opts.fetch(:export_name,       @name)
      @miq_import_method = opts.fetch(:miq_import_method, :partial)
      @miq_priority      = opts.fetch(:miq_priority,      10)
      @branch_name       = opts.fetch(:branch_name,       'No Branch')
    end

    # Filter changed files in this Automate domain from the list of all files
    #
    def _limit_changeset(files)
      @changeset = files.select{ |f| 
        $ligger.warn("TRAVIS in limit: #{@export_name} includes #{f}")
        f.include?(@export_name) 
      }
    end

    # create a new MiqDomain Object from information on the file system
    # @see #find_domain_files
    #
    # @param [Hash] dom domain information
    # @return [GitFlow::MiqDomain] new MiqDomain object
    def self.create_from_file(dom)
      opts = {}
      opts[:export_name]   = dom[:domain_name]
      opts[:export_dir]    = File.dirname(dom[:relative_path])
      opts[:import_method] = dom[:import_method]
      opts[:provider_name] = dom[:provider]
      opts[:branch_name]   = dom[:branch_name]

      new_name = "feature_#{dom[:feature_name]}_#{opts[:export_name]}"
      opts.reject!{ |_, value| value.nil? }
      self.new(new_name, opts)
    end

    # NOT IN USE
    #
    def self.create_from_config(name, opts)
      self.new(name, opts)
    end

    # Represents a Auromate Domain
    #
    # @param [String] name for the imported domain
    # @option opts @see _set_defaults
    # @option opts [String] :provider_name CHOICE: noop, local, docker
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
    rescue NoMethodError
      { error: true, miq_import_method: @miq_import_method }
    end

    def cleanup_import(prep_data)
      self.send("cleanup_import_#{@miq_import_method}".to_sym, prep_data)
    rescue NoMethodError
      { error: true, miq_import_method: @miq_import_method }
    end

    def skip_deploy?(opts)
      skippable_method = [:partial].include?(@miq_import_method)
      skip = skippable_method && opts[:changeset].empty?()
      $logger.info("Skipping Domain: #{@name}: empty") if skip
      skip
    end

    # Deploys (aka import) Automate Domains to ManageIQ
    #
    # @option opts [Array<String>] :changeset changed files according to git
    # @option opts [Boolean] :skip_emtpy do not create an empty domain if changeset is empty
    def deploy(opts)
      $logger.warn("TRAVIS: method=#{@miq_import_method} changeset=#{opts[:changeset]}")
      opts[:changeset] = _limit_changeset(opts.fetch(:changeset, []))
      $logger.warn("TRAVIS: method=#{@miq_import_method} changeset=#{opts[:changeset]}")
      return if skip_deploy?(opts)

      prep_data = prepare_import(self, opts)
      raise GitFlow::Error, "Unknown Import method: #{@miq_import_method}" if prep_data[:error] == true

      @miq_provider.import(File.join(prep_data[:import_dir], @export_dir), @export_name, @name)
      clean_data = cleanup_import(prep_data)
      raise GitFlow::Error, "Error calling cleanup method: #{@miq_import_method}" if clean_data[:error] == true
    end
  end
end
