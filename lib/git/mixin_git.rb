require 'rugged'

module GitFlow
  # The module where all the git related stuff goes in
  module GitMethods

    # This sets up the git half of a feature
    # 
    # @git_base: The baseline Rugged::Commit to diff against
    # @git_branch: Rugged::Branch of origin/<branch> 
    #
    # @param [String] branch_name The branch-name as string
    # @param [Rugged::Repository] repo
    def _create_git(branch_name, repo)
      rbranch = "#{@remote_name}/#{branch_name}"
      @git_base   = merge_base(repo, rbranch)
      @git_branch = repo.branches[rbranch]

      raise "Unable to find base branch: #{@base}"        if @git_base.nil?()
      raise "Unable to find feature branch: #{branch_name}" if @git_branch.nil?()
    end

    # Find the merge_base commit
    # https://git-scm.com/docs/git-merge-base
    #
    # @param [Rugged::Repository] repo 
    # @param [String] oid1 
    # @param [String] oid2 defaults to @base => 'master'
    # @return [Rugged::Commit, nil] 
    def merge_base(repo, oid1, oid2=nil)
     oid2 = oid2 || @base || 'master'

     base = repo.merge_base(oid1, oid2)
     base.nil?() ? nil : repo.lookup(base)
    end
  
    # Get a list of changed files 
    #
    # @param [Rugged::Commit, Rugged::Branch] base defaults to @git_base
    # @param [Rugged::Commit, Rugged::Branch] base defaults to @git_branch
    # @return [Array<String>] A list of changed paths
    def get_diff_paths(base=nil, head=nil)
      base = base || @git_base
      head = head || @git_branch

      raise "Diff failed: base is nil"   if base.nil?
      raise "Diff failed: branch is nil" if head.nil?

      paths = []
      base_commit = base.kind_of?(Rugged::Reference) ? base.target : base
      head_commit = head.kind_of?(Rugged::Reference) ? head.target : head

      diff = base_commit.diff(head_commit)
      diff.each_delta do |delta|
        next if delta.deleted?()
        paths << delta.new_file[:path]
      end
      paths
    end

#    def self._sync_branches(repo)
#      remotes = repo.branches.each(:remote).select{|remote_branch| @@prefixes.any?{|prefix| remote_branch.name.match("#{@@remote_name}/#{prefix}")  } }
#      $logger.debug("_sync_branches: Found Remotes #{remotes.map{|r| r.name}}")
#      locals = repo.branches.each_name(:local).sort
#
#      branch_diff = remotes.map do |r|
#        next nil if locals.any?{|local_branch_name| r.name == local_branch_name  }
#
#        $logger.debug("Creating Branch: #{r.name}")
#        
#      end
#      branch_diff.compact()
#    end

  end
end
