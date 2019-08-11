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

      Partial.create_fake_domain(import_dir, dom.export_dir, dom.export_name, dom.branch_name, dom.miq_priority)
      Partial.copy_to_tmp(import_dir, base_dir, Partial.file_list(feat[:changeset], base_dir))
      repo = Git.new(import_dir, $git_repo)
      repo.headless_commit(dom.name, "Import-Branch for #{dom.name} from #{dom.branch_name}")
      { import_dir: import_dir, git_url: repo.remote.url, ref_type: 'branch', ref_name: repo.branch.name, repo: repo }
    end

    def cleanup_import_git(_prep_data)
      {}
    end

    # Implementation for git import
    class Git
      attr_reader :remote, :branch

      def initialize(import_dir, global_repo)
        $logger.debug("Initialize temporary repo at: #{import_dir}: remote=#{global_repo.remotes['origin'].url}")
        @repo   = Rugged::Repository.init_at(import_dir)
        @author = { email: 'ghost@graveyard.com', name: 'Git Ghost' }
        @remote = @repo.remotes.create_anonymous(global_repo.remotes['origin'].url)
        user    = $settings[:git][:user]
        pass    = $settings[:git][:password]
        @cred   = Rugged::Credentials::UserPassword.new(username: user, password: pass)
      end

      def headless_commit(dom_name, message=nil)
        message ||= "Create headless commit for #{dom_name} at #{@repo.workdir}"
        index = @repo.index

        index.add_all
        tree_oid = index.write_tree
        commit_oid = Rugged::Commit.create(
          @repo,
          author: @author,
          committer: @author,
          message: message,
          parents: [],
          tree: tree_oid
        )
        @branch = @repo.branches.create("tmp_miqflow_#{dom_name}", commit_oid, force: true)
        @repo.checkout(@branch.name, strategy: :force)
        $logger.debug("Created branch #{@branch_name} on commit #{commit_oid}")
      end

      def check_connection
        @remote.check_connection(:push, credentials: @cred)
        true
      rescue Rugged::Error
        false
      end

      def push(ref_spec)
        unless check_connection()
          $logger.error("Failed to connect to #{@remote.url}: Are the credentials valid?")
          raise "Connection Error"
        end

        begin
          $logger.debug("Push: #{ref_spec}")
          @remote.push([ref_spec], credentials: @cred)
        rescue Rugged::Error => e
          $logger.error(e)
          raise
        end
      end

      def force_push(ref_spec)
        old_ref = ref_spec.split(':')[0]
        refs    = @remote.ls(credentials: @cred)

        if !old_ref.nil? && refs.any?{ |ref_info| ref_info[:name] == old_ref }
          $logger.debug("Force pushed #{ref_spec}: Deleting old Ref '#{old_ref}'")
          push(":#{old_ref}")
        end

        push(ref_spec)
      end

      def push_to_upstream
        force_push("refs/heads/#{@branch.name}")
      end

      def delete_from_upstream
        push(":refs/heads/#{@branch.name}")
      end
    end
  end
end
