require 'rugged'

module GitFlow
  module GitMethods
  
    def self._sync_branches(repo)
      remotes = repo.branches.each(:remote).select{|remote_branch| @@prefixes.any?{|prefix| remote_branch.name.match("#{@@remote_name}/#{prefix}")  } }
      $logger.debug("_sync_branches: Found Remotes #{remotes.map{|r| r.name}}")
      locals = repo.branches.each_name(:local).sort

      branch_diff = remotes.map do |r|
        next nil if locals.any?{|local_branch_name| r.name == local_branch_name  }

        $logger.debug("Creating Branch: #{r.name}")
        
      end
      branch_diff.compact()
    end

    def get_diff_paths(base=nil, branch=nil)
      base   = base   || @git_master
      branch = branch || @git_branch

      raise "Diff failed: base is nil"   if base.nil?
      raise "Diff failed: branch is nil" if branch.nil?

      paths = []
      diff = base.target.diff(branch.target)
      diff.each_delta do |delta| 
        paths << delta.new_file[:path]
      end
      paths
    end

  end
end
