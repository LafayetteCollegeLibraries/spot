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

  describe '#download_url' do
    subject { presenter.download_url }

    let(:presenter) { described_class.new(solr_doc, ability, mock_request) }
    let(:member_id) { 'fsa123bcd' }
    let(:member_presenter) { instance_double(Hyrax::FileSetPresenter, id: member_id, to_param: member_id) }
    let(:mock_request) { Struct.new(:host).new('localhost')  }

    context 'when a representative exists' do
      before do
        allow(solr_doc).to receive(:representative_id).and_return(member_id)
        allow_any_instance_of(Hyrax::MemberPresenterFactory).to receive(:member_presenters).with([member_id]).and_return([member_presenter])
      end

      it { is_expected.to eq "https://localhost/downloads/#{member_id}" }
    end

    context 'when a representative does not exist' do
      let(:member_id) { nil }

      it { is_expected.to eq '' }
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
    let(:solr_data) { { id: 'abc123def' }.merge(_solr_data) }
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

  describe '#citation_journal_title' do
    subject { presenter.citation_journal_title }

    let(:solr_data) do
      {
        'citation_journal_title_ss' => 'Journal'
      }
    end

    it { is_expected.to eq 'Journal' }
  end

  describe '#citation_volume' do
    subject { presenter.citation_volume }

    let(:solr_data) do
      {
        'citation_volume_ss' => '1'
      }
    end

    it { is_expected.to eq '1' }
  end

  describe '#citation_issue' do
    subject { presenter.citation_issue }

    let(:solr_data) do
      {
        'citation_issue_ss' => '2'
      }
    end

    it { is_expected.to eq '2' }
  end

  describe '#citation_firstpage' do
    subject { presenter.citation_firstpage }

    let(:solr_data) do
      {
        'citation_firstpage_ss' => '1'
      }
    end

    it { is_expected.to eq '1' }
  end

  describe '#citation_lastpage' do
    subject { presenter.citation_lastpage }

    let(:solr_data) do
      {
        'citation_lastpage_ss' => '2'
      }
    end

    it { is_expected.to eq '2' }
  end
end
