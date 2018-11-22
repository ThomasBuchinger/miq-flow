require 'tmpdir'
require 'yaml'
module GitFlow
  # This module contains everything needed to prepare an Automate domain for import
  # Mostly file handling at this point
  module MiqMethods
    def prepare_import_partial(dom, feat)
      $logger.debug("Doing a partial import of #{feat[:changeset].join(', ')}")
      base_dir   = feat[:git_workdir].to_s
      import_dir = File.join($tmpdir, 'import')

      Partial.create_fake_domain(import_dir, dom.export_dir, dom.export_name, dom.branch_name, dom.miq_priority)
      Partial.copy_to_tmp(import_dir, base_dir, Partial.file_list(feat[:changeset], base_dir))
      { import_dir: import_dir }
    end

    def cleanup_import_partial(_prep_data)
      {}
    end

    # Implementation for partial import
    module Partial
      def self.find_parent_files(base_dir, paths)
        parent_files = Dir.glob("#{base_dir}**/*").map{ |f| f.gsub(base_dir, '') }.select() do |file|
          keep = true
          keep &= %w[__namespace__.yaml __class__.yaml].include?(File.basename(file))
          keep &= paths.any?{ |p| p.start_with?(File.dirname(file)) }
          keep
        end
        parent_files
      end

      def self.create_fake_domain(import_dir, automate_dir, domain_name, branch_name, priority)
        domain = generate_domain_template(domain_name, branch_name, priority, 1)
        filename = File.join(import_dir, automate_dir, domain_name, '__domain__.yaml')
        $logger.debug("Creating Fake domain at #{filename}")

        FileUtils.mkdir_p(File.dirname(filename))
        File.write(filename, domain.to_yaml())
      end

      def self.generate_domain_template(domain_name, branch_name, priority, tenant)
        attributes = { display_name: nil, enabled: true, source: 'user', top_level_namespace: nil }
        domain = { object_type: 'domain', version: 1.0, object: { attributes: attributes } }
        domain['object']['attributes']['name']         = domain_name
        domain['object']['attributes']['description']  = "Development Branch for feature #{domain_name}: #{branch_name}"
        domain['object']['attributes']['priority']     = priority
        domain['object']['attributes']['tenant_id']    = tenant
        domain
      end

      def self.file_list(changeset, base_dir)
        method_data = changeset.map{ |p| p.gsub(/rb$/, 'yaml') }
        changeset + method_data + find_parent_files(base_dir, changeset)
      end

      def self.copy_to_tmp(import_dir, base_dir, all_files)
        $logger.debug("Copy to #{import_dir} Files: #{all_files}")
        all_files.each do |file|
          FileUtils.mkdir_p(File.join(import_dir, File.dirname(file)))
          FileUtils.cp(File.expand_path(file, base_dir), File.join(import_dir, file), preserve: true)
        end
        import_dir
      end
    end
  end
end
