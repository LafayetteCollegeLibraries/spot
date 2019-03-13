# frozen_string_literal: true
require 'tmpdir'

RSpec.describe Spot::WorkCSVService do
  let(:service) { described_class.new(work, terms: terms) }
  let(:work) { build(:publication, id: 'abc123', title: ['one title', 'two titles']) }
  let(:terms) { %i[id title creator] }
  let(:expected_headers) { "id,title,creator\n" }
  let(:expected_content) do
    %(#{work.id},#{work.title.map(&:to_s).join('|')},"#{work.creator.map(&:to_s).join('|')}"\n)
  end

  describe '#headers' do
    subject { service.headers }

    it { is_expected.to be_a String }
    it { is_expected.to eq expected_headers }

    # this is gross but i want to confirm that we're using the default terms
    context 'when no terms are provided' do
      subject { described_class.new(work).headers }

      it { is_expected.to eq service.send(:default_terms).join(',') + "\n" }
    end
  end

  describe '#content' do
    subject { service.content }

    it { is_expected.to be_a String }
    it { is_expected.to eq expected_content }

    context 'when a field does not exist on a work' do
      let(:service) { described_class.new(work, terms: [:id, :nope_not_here]) }

      it { is_expected.to eq %(#{work.id},""\n) }
    end
  end

  describe '#csv' do
    subject { service.csv }

    let(:content) { expected_headers + expected_content }

    it { is_expected.to eq content }

    context 'when no headers wanted' do
      let(:service) { described_class.new(work, terms: terms, include_headers: false) }

      it { is_expected.to eq expected_content }
      it { is_expected.not_to include expected_headers }
    end
  end
end
