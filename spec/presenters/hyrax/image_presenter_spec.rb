# frozen_string_literal: true

RSpec.describe Hyrax::ImagePresenter do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(:image) }
  let(:ability) { Ability.new(build(:user)) }

  it_behaves_like 'a Spot presenter'
  it_behaves_like 'it exports image derivatives'

  describe '#subject_ocm' do
    subject { presenter.subject_ocm }

    let(:object) { build(:image, subject_ocm: values) }

    let(:values) do
      ['640 STATE', '340 STRUCTURES', '644 EXECUTIVE HOUSEHOLD', '344 PUBLIC STRUCTURES']
    end

    let(:sorted_values) do
      ['340 STRUCTURES', '344 PUBLIC STRUCTURES', '640 STATE', '644 EXECUTIVE HOUSEHOLD']
    end

    it { is_expected.to eq sorted_values }
  end
end
