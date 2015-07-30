require "pull_request_monitor/repo_processor"
require "pull_request_monitor/pr_processor"

module PullRequestMonitor
  def self.process_repos
    CommitMonitorRepo.includes(:branches).each do |repo|
      next unless repo.upstream_user
      repo.with_git_service do |git|
        repo.with_github_service do |github|
          RepoProcessor.new(repo, git, github).process
        end
      end
    end
  end
end
