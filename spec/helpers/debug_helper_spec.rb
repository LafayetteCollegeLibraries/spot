# frozen_string_literal: true
RSpec.describe DebugHelper do
  let(:base_url) { 'https://github.com/LafayetteCollegeLibraries/spot' }
  describe '#link_to_git_branch' do
    subject { Nokogiri::HTML(helper.link_to_git_branch) }

    let(:branch) { `git rev-parse --abbrev-ref HEAD`.strip }
    let(:url) { "#{base_url}/tree/#{branch}" }
    let(:element) { Nokogiri::HTML(%(<a target="_blank" href="#{url}">#{branch}</a>)) }

    it { is_expected.to be_equivalent_to element }
  end

  describe '#link_to_latest_gh_commit' do
    subject { Nokogiri::HTML(helper.link_to_latest_gh_commit) }

    let(:commit) { `git rev-parse HEAD`.strip }
    let(:url) { "#{base_url}/commit/#{commit}" }
    let(:element) do
      Nokogiri::HTML(%(<a target="_blank" href="#{url}">#{commit[0..6]}</a>))
    end

    it { is_expected.to be_equivalent_to element }
  end
end
