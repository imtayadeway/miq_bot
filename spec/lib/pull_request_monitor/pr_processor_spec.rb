require "spec_helper"
require "pull_request_monitor"

RSpec.describe PullRequestMonitor::PrProcessor do
  describe "#process" do
    it "does something" do
      git = double("git")
      allow(git).to receive(:pr_branch).with(123).and_return("feature/add-doodads")
      allow(git).to receive(:create_pr_branch).with("feature/add-doodads")
      allow(git).to receive(:merge_base).with("feature/add-doodads", "master").and_return("111111")

      branch = double("branch", :pull_request? => true, :name => "feature/add-doodads")

      branches = double("branches")
      allow(branches).to receive(:select).and_yield(branch).and_return([branch])

      repo = double("repo", :branches => branches)

      pr = double("PR", :number => 123)
      allow(pr).to receive_message_chain(:head, :repo, :html_url).and_return("http://example.com/foo/bar")
      processor = described_class.new(repo, pr, git)

      expect { processor.process }.not_to raise_error
    end

    it "does something else when the pr branch record not there" do
      git = double("git")
      allow(git).to receive(:pr_branch).with(123).and_return("feature/add-doodads")
      allow(git).to receive(:create_pr_branch).with("feature/add-doodads")
      allow(git).to receive(:merge_base).with("feature/add-doodads", "master").and_return("111111")

      branch = double("branch", :pull_request? => true, :name => "feature/add-doodads")

      branches = double("branches")
      allow(branches).to receive(:select).and_yield(branch).and_return([])
      allow(branches).to receive(:create!)

      repo = double("repo", :branches => branches)

      pr = double("PR", :number => 123)
      allow(pr).to receive_message_chain(:head, :repo, :html_url).and_return("http://example.com/foo/bar")

      processor = described_class.new(repo, pr, git)

      expect { processor.process }.not_to raise_error
    end
  end
end
