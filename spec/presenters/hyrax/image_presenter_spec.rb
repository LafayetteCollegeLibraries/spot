# frozen_string_literal: true

RSpec.describe Hyrax::ImagePresenter do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(:publication) }
  let(:ability) { Ability.new(build(:user)) }

  it_behaves_like 'a Spot presenter'

  describe '#subject_ocm' do
    subject { presenter.subject_ocm }

    let(:values) do
      ['640 STATE', '340 STRUCTURES', '644 EXECUTIVE HOUSEHOLD', '344 PUBLIC STRUCTURES']
    end

    let(:sorted_values) do
      ['340 STRUCTURES', '344 PUBLIC STRUCTURES', '640 STATE', '644 EXECUTIVE HOUSEHOLD']
    end

    it { is_expected.to eq sorted_values }
  end
end
