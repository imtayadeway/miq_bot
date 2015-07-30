module PullRequestMonitor
  class PrProcessor
    attr_reader :repo, :pr, :git

    def initialize(repo, pr, git)
      @repo = repo
      @pr = pr
      @git = git
    end

    def process
      branch_name = git.pr_branch(pr.number)
      return if repo.pr_branches_include?(branch_name)
      git.create_pr_branch(branch_name)
      last_commit = git.merge_base(branch_name, "master")
      repo.create_pr_branch!(branch_name, last_commit, commit_uri)
    end

    private

    def commit_uri
      File.join(pr.head.repo.html_url, "commit", "$commit")
    end
  end
end
