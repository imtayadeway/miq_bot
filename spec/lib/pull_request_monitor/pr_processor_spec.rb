require "spec_helper"
require "pull_request_monitor"

RSpec.describe PullRequestMonitor::PrProcessor do
  describe "#process" do
    context "when a record of the PR branch exists" do
      it "does nothing" do
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

      it "returns the branch name" do
        branch_name = "feature/add-doodad"
        pr_number = 123

        git = double("git")
        allow(git).to receive(:pr_branch).with(pr_number).and_return(branch_name)

        repo = double("repo")
        allow(repo).to receive(:pr_branches_include?).with(branch_name).and_return(true)

        pr = double("PR", :number => pr_number)

        expect(described_class.new(repo, pr, git).process).to eq(branch_name)
      end
    end

    context "when a record of the PR branch does not exist" do
      it "ensures pr branch record is created" do
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

      it "returns the branch name" do
        branch_name = "feature/add-doodad"
        pr_number = 123

        git = double("git")
        allow(git).to receive(:pr_branch).with(pr_number).and_return(branch_name)
        allow(git).to receive(:merge_base).with(branch_name, "master").and_return("111111")
        allow(git).to receive(:create_pr_branch).with(branch_name)

        repo = double("repo")
        allow(repo).to receive(:pr_branches_include?).with(branch_name).and_return(false)
        allow(repo).to receive(:create_pr_branch!)

        pr = double("PR", :number => pr_number)
        allow(pr).to receive_message_chain(:head, :repo, :html_url)
                      .and_return("http://github.com/foo/bar/commit/$commit")

        expect(described_class.new(repo, pr, git).process).to eq(branch_name)
      end
    end
  end
end
