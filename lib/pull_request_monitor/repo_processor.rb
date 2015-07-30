module PullRequestMonitor
  class RepoProcessor
    attr_reader :repo, :git, :github

    def initialize(repo)
      @repo = repo
      repo.with_git_service { |git| @git = git }
      repo_with_github_service { |github| @github = github }
    end

    def process
      git.checkout("master")
      git.pull

      original_pr_branches = pr_branches
      current_pr_branches  = process_prs
      delete_pr_branches(original_pr_branches - current_pr_branches)
    end

    private

    def pr_branches
      repo.branches.select(&:pull_request?).collect(&:name)
    end

    def process_prs
      github.pull_requests.all.collect do |pr|
        PrProcessor.new(repo, pr, git).process
      end
    end

    def delete_pr_branches(branch_names)
      return if branch_names.empty?

      repo.branches.where(:name => branch_names).destroy_all

      git.checkout("master")
      branch_names.each { |branch_name| git.destroy_branch(branch_name) }
    end
  end
end
