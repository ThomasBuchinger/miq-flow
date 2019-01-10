# frozen_string_literal: true

require 'tmpdir'
require 'yaml'

module GitFlow
  # This module contains everything needed to prepare an Automate domain for import
  # Mostly file handling at this point
  module MiqMethods
    def prepare_import_clean(_dom, _opts)
      { import_dir: $git_repo.workdir.chomp('/') }
    end

    def cleanup_import_clean(_prep_data)
      {}
    end
  end
end
