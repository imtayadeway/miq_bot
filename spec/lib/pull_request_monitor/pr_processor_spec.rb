require "spec_helper"
require "pull_request_monitor"

RSpec.describe PullRequestMonitor::PrProcessor do
  describe "#process" do
    it "does nothing if a record of the PR branch exists" do
      branch_name = "feature/add-doodad"
      pr_number = 123

      git = double("git")
      allow(git).to receive(:pr_branch).with(pr_number).and_return(branch_name)

      repo = double("repo")
      allow(repo).to receive(:pr_branches_include?).with(branch_name).and_return(true)

      pr = double("PR", :number => pr_number)

      expect(git).not_to receive(:create_pr_branch).with(branch_name)
      expect(repo).not_to receive(:create_pr_branch!)

      described_class.new(repo, pr, git).process
    end

    it "ensures pr branch record is created if it does not exist" do
      branch_name = "feature/add-doodad"
      pr_number = 123

      git = double("git")
      allow(git).to receive(:pr_branch).with(pr_number).and_return(branch_name)
      allow(git).to receive(:merge_base).with(branch_name, "master").and_return("111111")

      repo = double("repo")
      allow(repo).to receive(:pr_branches_include?).with(branch_name).and_return(false)

      pr = double("PR", :number => pr_number)
      allow(pr).to receive_message_chain(:head, :repo, :html_url)
        .and_return("http://github.com/foo/bar/commit/$commit")

      expect(git).to receive(:create_pr_branch).with(branch_name)
      expect(repo).to receive(:create_pr_branch!)

      described_class.new(repo, pr, git).process
    end
  end
end
