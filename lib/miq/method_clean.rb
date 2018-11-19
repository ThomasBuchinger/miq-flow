require 'tmpdir'
require 'yaml'
module GitFlow
  # This module contains everything needed to prepare an Automate domain for import
  # Mostly file handling at this point
  module MiqMethods
    def prepare_import_clean(feature)
      $git_repo.workdir.chomp('/')
    end
    def cleanup_import_clean()
    end

  end
end
