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

      unless pr_branches.include?(branch_name)
        git.create_pr_branch(branch_name)
        create_pr_branch_record(branch_name)
      end

      branch_name
    end

    private

    def pr_branches
      repo.branches.select(&:pull_request?).collect(&:name)
    end

    def create_pr_branch_record(branch_name)
      commit_uri  = File.join(pr.head.repo.html_url, "commit", "$commit")
      last_commit = git.merge_base(branch_name, "master")
      repo.branches.create!(
        :name         => branch_name,
        :last_commit  => last_commit,
        :commits_list => [],
        :commit_uri   => commit_uri,
        :pull_request => true
      )
    end
  end
end
