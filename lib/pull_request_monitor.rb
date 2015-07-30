require "pull_request_monitor/repo_processor"
require "pull_request_monitor/pr_processor"

module PullRequestMonitor
  def self.process_repos
    CommitMonitorRepo.includes(:branches).each do |repo|
      next unless repo.upstream_user
      RepoProcessor.new(repo).process
    end
  end
end
