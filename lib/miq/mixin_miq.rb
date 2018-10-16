require 'tmpdir'
require 'yaml'
module GitFlow
  module MiqMethods
    def prepare_import(method, paths)
      self.send("prepare_import_#{method}".to_sym, paths)
    end
    def cleanup_import(method)
      self.send("cleanup_import_#{method}".to_sym)
    end

    def prepare_import_dirty(feature)
      base_dir = "#{$git_repo.workdir}"
      @tmpdir = Dir.mktmpdir('miq_import_')

      paths            = get_diff_paths()
      method_data      = paths.map{|p| p.gsub(/rb$/, 'yaml') }
      $logger.debug("Doing a dirty import of #{paths.join(', ')}")
      all_files        = paths + method_data + _dirty_import_find_parent_files(base_dir, paths)
      
      fake_domain_file = _dirty_import_fake_domain(@tmpdir, feature)
      _dirty_import_copy_to_tmp(@tmpdir, base_dir, all_files)
      @tmpdir
    end
    def cleanup_import_dirty()
      FileUtils::rm_rf(@tmpdir) unless @tmpdir.nil?
    end
    def _dirty_import_find_parent_files(base_dir, paths)
      parent_files = Dir.glob("#{base_dir}#{@automate_dir}/**/*").map{|f| f.gsub(base_dir, '') }.select() do |file|
        keep = true
        keep &= ['__namespace__.yaml', '__class__.yaml'].include?(File.basename(file))
        keep &= paths.any?{ |p| p.start_with?(File.dirname(file)) }
        keep 
      end
      parent_files
    end
    def _dirty_import_fake_domain(tmpdir, feature_name)
      domain = {'object_type'=>'domain', 'version'=>1.0, 'object'=>{'attributes'=>{}}}
      domain['object']['attributes']['name']         = feature_name
      domain['object']['attributes']['description']  = "Development Branch for #{feature_name}"
      domain['object']['attributes']['display_name'] = nil
      domain['object']['attributes']['priority']     = @miq_priority
      domain['object']['attributes']['enabled']      = true
      domain['object']['attributes']['tenant_id']    = 1 
      domain['object']['attributes']['source']       = 'user'
      domain['object']['attributes']['top_level_namespace'] = nil 
      filename = File.join(tmpdir, @automate_dir, feature_name, '__domain__.yaml')
      $logger.debug("Creating Fake domain at #{filename}")

      FileUtils.mkdir_p(File.dirname(filename))
      File.write(filename, domain.to_yaml())
    end
    def _dirty_import_copy_to_tmp(tmpdir, base_dir, all_files)
      $logger.debug("Copy to #{tmpdir} Files: #{all_files}")
      all_files.each do |file|
        FileUtils.mkdir_p(tmpdir+'/'+File.dirname(file))
        FileUtils.cp(File.expand_path(file, base_dir), tmpdir+'/'+file, :preserve=>true)
      end
      tmpdir
    end

  end
end
