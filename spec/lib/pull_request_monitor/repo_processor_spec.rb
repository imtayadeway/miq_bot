require "spec_helper"
require "pull_request_monitor"

describe PullRequestMonitor::RepoProcessor do
  it "pulls from master" do
    repo = spy("repo")
    git = spy("git")
    github = spy("github")

    expect(git).to receive(:checkout).with("master").ordered
    expect(git).to receive(:pull).ordered

    described_class.new(repo, git, github).process
  end

  it "processes any PRs" do
    repo = spy("repo")
    git = spy("git")
    github = spy("github")
    pr = double("PR")
    pr_processor = double("PR processor")

    allow(github).to receive_message_chain(:pull_requests, :all).and_return([pr])
    allow(PullRequestMonitor::PrProcessor).to receive(:new).with(repo, pr, git).and_return(pr_processor)
    expect(pr_processor).to receive(:process)

    described_class.new(repo, git, github).process
  end


  it "deletes any obsolete branches" do
    current_branch = "feature/add-hoojameflip"
    obsolete_branch = "feature/add-doodad"

    repo = spy("repo", :pr_branch_names => [current_branch, obsolete_branch])
    git = spy("git")
    github = spy("github")
    pr = double("PR")
    pr_processor = double("PR processor", :process => current_branch)

    allow(github).to receive_message_chain(:pull_requests, :all).and_return([pr])
    allow(PullRequestMonitor::PrProcessor).to receive(:new).with(repo, pr, git).and_return(pr_processor)

    expect(repo).to receive(:destroy_all_branches).with([obsolete_branch])
    expect(git).to receive(:checkout).with("master").ordered
    expect(git).to receive(:destroy_branch).with(obsolete_branch).ordered

    described_class.new(repo, git, github).process
  end
end
