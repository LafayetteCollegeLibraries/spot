# frozen_string_literal: true
RSpec.shared_examples 'a Spot presenter' do
  subject(:presenter) { described_class.new(solr_doc, ability) }

  let(:solr_doc) { SolrDocument.new(solr_data) }
  let(:solr_data) { object.to_solr }
  let(:object) { build(factory) }
  let(:factory) { described_class.name.split('::').last.gsub(/Presenter/, '').underscore.to_sym }
  let(:ability) { Ability.new(build(:user)) }

  it_behaves_like 'it renders an attribute to HTML'

  describe 'delegated solr_document methods' do
    let(:solr_doc) { instance_double(SolrDocument) }

    [
      :contributor, :creator, :description, :identifier, :keyword, :note, :permalink,
      :physical_medium, :publisher, :related_resource, :resource_type, :rights_holder,
      :rights_statement, :source, :subtitle, :title_alternative, :title, :visibility
    ].each do |method_name|
      describe "##{method_name}" do
        subject { presenter.public_send(method_name) }

        let(:dummy_value) { method_name == :visibility ? 'visibility value' : ['some values', 'and others'] }

        before { allow(solr_doc).to receive(method_name).and_return(dummy_value) }

        it { is_expected.to eq dummy_value }
      end
    end
  end

  describe '#export_formats' do
    subject { presenter.export_formats }

    it { is_expected.to include :csv, :ttl, :nt, :jsonld }
  end

  context 'identifier handling' do
    let(:raw_ids) { ['issn:1234-5678', 'abc:123'] }
    let(:object) { build(:publication, identifier: raw_ids) }

    describe '#local_identifier' do
      subject(:ids) { presenter.local_identifier }

      it 'returns only the identifiers that return true to #local?' do
        expect(ids.map(&:to_s)).to eq ['abc:123']
      end

      it 'maps identifiers to Spot::Identifier objects' do
        expect(ids.all? { |id| id.is_a? Spot::Identifier }).to be true
      end
    end

    describe '#standard_identifier' do
      subject(:ids) { presenter.standard_identifier }

      it 'returns only the identifiers that return true to #standard?' do
        expect(ids.map(&:to_s)).to eq ['issn:1234-5678']
      end

      it 'maps identifiers to Spot::Identifier objects' do
        expect(ids.all? { |id| id.is_a? Spot::Identifier }).to be true
      end
    end
  end

  describe '#location' do
    subject { presenter.location }

    let(:uri) { 'http://sws.geonames.org/5188140/' }
    let(:label) { 'United States, Pennsylvania, Northampton County, Easton' }
    let(:solr_data) do
      {
        'location_ssim' => [uri],
        'location_label_tesim' => [label]
      }
    end

    it { is_expected.to eq [[uri, label]] }
  end

  describe '#metadata_only?' do
    subject { presenter.metadata_only? }

    let(:admin_ability) { Ability.new(build(:admin_user)) }
    let(:registered_ability) { Ability.new(build(:registered_user)) }
    let(:has_model_string) { factory.to_s.camelcase.constantize.to_s }
    let(:solr_data) { { id: 'abc123def', has_model_ssim: [has_model_string] }.merge(_solr_data) }
    let(:_solr_data) { {} }

    # `metadata_only?` calls `can?(:read, solr_document)` so the data needs to be persisted
    before { ActiveFedora::SolrService.add(solr_data, commit: true) }
    after { ActiveFedora::SolrService.delete(solr_data[:id]) }

    context 'when the ability is admin' do
      let(:ability) { admin_ability }

      it { is_expected.to be false }
    end

    context "when an item's visibility is 'metadata'" do
      let(:_solr_data) { { 'visibility_ssi' => 'metadata' } }

      it { is_expected.to be true }
    end

    context 'when an item is restricted to authenticated users' do
      let(:_solr_data) { { 'read_access_group_ssim' => [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED] } }

      context 'with an unauthenticated user' do
        let(:ability) { Ability.new(build(:public_user)) }

        it { is_expected.to be true }
      end

      context 'with an authenticated user' do
        let(:ability) { registered_ability }

        it { is_expected.to eq false }
      end
    end
  end

  describe '#page_title' do
    subject { presenter.page_title }

    it { is_expected.to include presenter.title.first }
    it { is_expected.to include 'Lafayette Digital Repository' }
  end

  describe '#public?' do
    subject { presenter.public? }

    context 'when object is public' do
      let(:object) { build(factory, :public) }

      it { is_expected.to be true }
    end

    context 'when object is not public' do
      let(:object) { build(factory, :authenticated) }

      it { is_expected.to be false }
    end
  end

  describe '#rights_statement_merged' do
    subject { presenter.rights_statement_merged }

    let(:uri) { 'http://creativecommons.org/publicdomain/mark/1.0/' }
    let(:label) { 'Public Domain Mark (PDM)' }

    let(:solr_data) do
      {
        'rights_statement_ssim' => [uri],
        'rights_statement_label_ssim' => [label]
      }
    end

    it { is_expected.to eq [[uri, label]] }
  end

  describe '#subject' do
    subject { presenter.subject }

    let(:uri) { 'http://id.worldcat.org/fast/2004076' }
    let(:label) { 'Little free libraries' }

    let(:solr_data) do
      {
        'subject_ssim': [uri],
        'subject_label_tesim': [label]
      }
    end

    it { is_expected.to eq [[uri, label]] }
  end

  describe '#work_featurable?' do
    subject { presenter.work_featurable? }

    it { is_expected.to be false }
  end
end
