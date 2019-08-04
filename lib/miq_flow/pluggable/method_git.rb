# frozen_string_literal: true

require 'tmpdir'
require 'yaml'
require_relative 'method_partial'

module MiqFlow
  # This module contains everything needed to prepare an Automate domain for import
  # Mostly file handling at this point
  module MiqMethods
    def prepare_import_git(dom, feat)
      $logger.debug("Doing a git import of #{feat[:changeset].join(', ')}")
      base_dir   = feat[:git_workdir].to_s
      import_dir = File.join($tmpdir, 'import')

      #Partial.create_fake_domain(import_dir, dom.export_dir, dom.export_name, dom.branch_name, dom.miq_priority)
      #Partial.copy_to_tmp(import_dir, base_dir, Partial.file_list(feat[:changeset], base_dir))
      #Git.init_repo(import_dir)
      # Git.push()
      { import_dir: import_dir, git_url: 'a', ref_type: 'branch', ref_name: 'b' }
    end

    def cleanup_import_git(_prep_data)
      {}
    end

    # Implementation for git import
    module Git
      def self.init_repo(import_dir)
      end
    end
  end
end
