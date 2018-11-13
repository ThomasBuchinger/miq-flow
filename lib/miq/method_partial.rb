require 'tmpdir'
require 'yaml'
module GitFlow
  # This module contains everything needed to prepare an Automate domain for import
  # Mostly file handling at this point
  module MiqMethods

    def prepare_import_partial(dom, feat)
      base_dir = "#{feat[:git_workdir]}"
      import_dir = File.join($tmpdir, 'import')

      paths            = feat[:changeset]
      method_data      = paths.map{|p| p.gsub(/rb$/, 'yaml') }
      $logger.debug("Doing a partial import of #{paths.join(', ')}")
      all_files        = paths + method_data + Partial.find_parent_files(base_dir, paths)
        
      fake_domain_file = Partial.create_fake_domain(File.join(import_dir, 'automate', dom.export_name), dom.name, dom.branch_name, dom.miq_priority)
      Partial.copy_to_tmp(import_dir, base_dir, all_files)
      { :import_dir => import_dir }
    end
    def cleanup_import_partial()
    end

    module Partial

      def self.find_parent_files(base_dir, paths)
        parent_files = Dir.glob("#{base_dir}**/*").map{|f| f.gsub(base_dir, '') }.select() do |file|
          keep = true
          keep &= ['__namespace__.yaml', '__class__.yaml'].include?(File.basename(file))
          keep &= paths.any?{ |p| p.start_with?(File.dirname(file)) }
          keep 
        end
        parent_files
      end
      def self.create_fake_domain(import_dir, domain_name, branch_name, priority)
        domain = {'object_type'=>'domain', 'version'=>1.0, 'object'=>{'attributes'=>{}}}
        domain['object']['attributes']['name']         = domain_name
        domain['object']['attributes']['description']  = "Development Branch for feature #{domain_name}: #{branch_name}"
        domain['object']['attributes']['display_name'] = nil
        domain['object']['attributes']['priority']     = priority
        domain['object']['attributes']['enabled']      = true
        domain['object']['attributes']['tenant_id']    = 1 
        domain['object']['attributes']['source']       = 'user'
        domain['object']['attributes']['top_level_namespace'] = nil 
        filename = File.join(import_dir, '__domain__.yaml')
        $logger.debug("Creating Fake domain at #{filename}")

        FileUtils.mkdir_p(File.dirname(filename))
        File.write(filename, domain.to_yaml())
      end
      def self.copy_to_tmp(import_dir, base_dir, all_files)
        $logger.debug("Copy to #{import_dir} Files: #{all_files}")
        all_files.each do |file|
          FileUtils.mkdir_p(File.join(import_dir, File.dirname(file)))
          FileUtils.cp(File.expand_path(file, base_dir), File.join(import_dir, file), :preserve=>true)
        end
        import_dir
      end
    end
  end
end
