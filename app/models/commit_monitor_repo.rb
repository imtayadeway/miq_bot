class CommitMonitorRepo < ActiveRecord::Base
  has_many :branches, :class_name => :CommitMonitorBranch, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => true
  validates :path, :presence => true, :uniqueness => true

  def self.create_from_github!(upstream_user, name, path)
    MiqToolsServices::MiniGit.call(path) do |git|
      git.checkout("master")
      git.pull

      repo = self.create!(
        :upstream_user => upstream_user,
        :name          => name,
        :path          => File.expand_path(path)
      )

      repo.branches.create!(
        :name        => "master",
        :commit_uri  => CommitMonitorBranch.github_commit_uri(upstream_user, name),
        :last_commit => git.current_ref
      )

      repo
    end
  end

  def create_pr_branch!(branch_name, last_commit, commit_uri)
    branches.create!(
      :name         => branch_name,
      :last_commit  => last_commit,
      :commits_list => [],
      :commit_uri   => commit_uri,
      :pull_request => true
    )
  end

  def fq_name
    "#{upstream_user}/#{name}"
  end
  alias_method :slug, :fq_name

  # fq_name: "ManageIQ/miq_bot"
  def self.with_fq_name(fq_name)
    user, repo = fq_name.split("/")
    CommitMonitorRepo.where(:upstream_user => user, :name => repo)
  end
  class << self
    alias_method :with_slug, :with_fq_name
  end

  def path=(val)
    super(File.expand_path(val))
  end

  def pr_branches
    branches.select(&:pull_request?)
  end

  def pr_branches_include?(branch_name)
    pr_branches.collect(&:name).include?(branch_name)
  end

  def with_git_service
    raise "no block given" unless block_given?
    MiqToolsServices::MiniGit.call(path) { |git| yield git }
  end

  def with_github_service
    raise "no block given" unless block_given?
    MiqToolsServices::Github.call(:repo => name, :user => upstream_user) { |github| yield github }
  end

  def with_travis_service
    raise "no block given" unless block_given?

    Travis.github_auth(Settings.github_credentials.password)
    yield Travis::Repository.find(fq_name)
  end

  def enabled_for?(checker)
    repos = Settings.public_send(checker).enabled_repos
    fq_name.in?(repos)
  end
end
