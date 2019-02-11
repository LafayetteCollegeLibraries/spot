# frozen_string_literal: true
#
# Some odds + ends to help get our bearings within the different
# dev/stage environments.
module DebugHelper
  # @return [String] html link to current git branch
  def link_to_git_branch
    branch_name = `git rev-parse --abbrev-ref HEAD`.strip
    url = "#{github_url_base}/tree/#{branch_name}"

    link_to(branch_name, url, target: '_blank')
  end

  # @return [String] html link to last commit on github
  def link_to_latest_gh_commit
    commit = `git rev-parse HEAD`.strip
    short_commit = commit[0..6]
    url = "#{github_url_base}/commit/#{commit}"

    link_to(short_commit, url, target: '_blank')
  end

  private

    # @return [String]
    def github_url_base
      'https://github.com/LafayetteCollegeLibraries/spot'
    end
end
