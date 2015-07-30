module PullRequestMonitor
  class RepoProcessor
    attr_reader :repo, :git, :github

    def initialize(repo, git, github)
      @repo = repo
      @git = git
      @github = github
    end

    def process
      git.checkout("master")
      git.pull

      original_pr_branches = repo.pr_branch_names
      current_pr_branches  = process_prs
      delete_pr_branches(original_pr_branches - current_pr_branches)
    end

    private

    def process_prs
      github.pull_requests.all.collect do |pr|
        PrProcessor.new(repo, pr, git).process
      end
    end

    def delete_pr_branches(branch_names)
      return if branch_names.empty?

      repo.destroy_all_branches(branch_names)

      git.checkout("master")
      branch_names.each { |branch_name| git.destroy_branch(branch_name) }
    end
  end
end
