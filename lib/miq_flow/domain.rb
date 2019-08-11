# frozen_string_literal: true

module MiqFlow
  # Represents a single ManageIQ Automate Domain on disk
  class MiqDomain
    include MiqFlow::MiqMethods

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
    def _set_defaults(opts={})
      @export_dir        = opts.fetch(:export_dir,        'automate')
      @export_name       = opts.fetch(:export_name,       @name)
      @miq_priority      = opts.fetch(:miq_priority,      10)
      @branch_name       = opts.fetch(:branch_name,       'No Branch')
    end

    # Filter changed files in this Automate domain from the list of all files
    #
    def _limit_changeset(files)
      @changeset = files.select{ |f| f.include?("#{@export_name}#{File::SEPARATOR}") && f.include?(@export_dir) }
    end

    # create a new MiqDomain Object from information on the file system
    # @see #find_domain_files
    #
    # @param [Hash] dom domain information
    # @return [MiqFlow::MiqDomain] new MiqDomain object
    def self.create_from_file(dom)
      opts = {}
      opts[:export_name]   = dom[:domain_name]
      opts[:export_dir]    = File.dirname(dom[:relative_path])
      opts[:import_method] = dom[:import_method]
      opts[:provider_name] = dom[:provider]
      opts[:branch_name]   = dom[:branch_name]
      opts[:miq_priority]  = dom.dig(:domain, 'object', 'attributes', 'priority')

      new_name = "feat_#{dom[:feature_name]}_#{opts[:export_name]}"
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

      @miq_import_method, @miq_provider = provider_from_name(opts[:provider_name])
    end

    def provider_from_name(name)
      return [:partial, MiqFlow::MiqProvider::Noop.new]      if name == 'noop'

      return [:git, MiqFlow::MiqProvider::Noop.new]          if name == 'noop-api'

      return [:partial, MiqFlow::MiqProvider::Appliance.new] if name == 'local'

      return [:partial, MiqFlow::MiqProvider::Docker.new]    if name == 'docker'

      return [:git, MiqFlow::MiqProvider::Api.new]           if name == 'api'

      [:partial, MiqFlow::MiqProvider::Noop.new]
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
      skippable_method = %i[partial git].include?(@miq_import_method)
      skip = skippable_method && opts[:changeset].empty?()
      $logger.info("Skipping Domain: #{@name}: empty") if skip
      skip
    end

    # Deploys (aka import) Automate Domains to ManageIQ
    #
    # @option opts [Array<String>] :changeset changed files according to git
    # @option opts [Boolean] :skip_emtpy do not create an empty domain if changeset is empty
    def deploy(opts)
      opts[:changeset] = _limit_changeset(opts.fetch(:changeset, []))
      return if skip_deploy?(opts)

      prep_data = prepare_import(self, opts)
      raise MiqFlow::UnknownStrategyError, "Unknown Import method: #{@miq_import_method}" if prep_data[:error] == true

      prep_data.merge!(import_dir: File.join(prep_data[:import_dir], @export_dir), fs_name: @export_name)
      @miq_provider.import(@name, prep_data)
      clean_data = cleanup_import(prep_data)
      raise MiqFlow::UnknownStrategyError, "Unknown cleanup method: #{@miq_import_method}" if clean_data[:error] == true
    end

    def file_data(git_workdir:, namespace:, klass:, name:)
      re = {}
      re[:path] = File.join(
        git_workdir,
        @export_dir,
        @export_name,
        namespace,
        "#{klass}.class",
        '__methods__',
        "#{name}.rb"
      )
      re[:meta_yaml]    = re[:path].gsub(/rb$/, 'yaml')
      re[:content]      = File.exist?(re[:path]) ? File.read(re[:path]) : ''
      re[:meta_content] = File.exist?(re[:meta_yaml]) ? File.read(re[:meta_yaml]) : ''
      re
    end

    def details(paths)
      {
        name: @name,
        export_name: @export_name,
        paths: _limit_changeset(paths)
      }
    end
  end
end
