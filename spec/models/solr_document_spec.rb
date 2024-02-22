# frozen_string_literal: true
RSpec.describe SolrDocument do
  let(:document) { described_class.new(metadata) }

  {
    abstract: { type: Array, suffix: 'tesim' },
    academic_department: { type: Array, suffix: 'tesim' },
    admin_set: { type: String, suffix: 'tesim' },
    bibliographic_citation: { type: Array, suffix: 'tesim' },
    collection_slug: { type: String, suffix: 'ssi' },
    contributor: { type: Array, suffix: 'tesim' },
    date: { type: Array, suffix: 'ssim' },
    date_available: { type: Array, suffix: 'ssim' },
    date_issued: { type: Array, suffix: 'ssim' },
    date_modified: {
      type: Date,
      suffix: 'dtsi',
      value: '2019-02-28T00:00:00Z',
      expected: Date.parse('2019-02-28T00:00:00Z')
    },
    date_scope_note: { type: Array, suffix: 'tesim' },
    date_uploaded: {
      type: Date,
      suffix: 'dtsi',
      value: '2019-02-28T00:00:00Z',
      expected: Date.parse('2019-02-28T00:00:00Z')
    },
    depositor: { type: String, suffix: 'ssim' },
    description: { type: Array, suffix: 'tesim' },
    donor: { type: Array, suffix: 'ssim' },
    division: { type: Array, suffix: 'tesim' },
    editor: { type: Array, suffix: 'tesim' },
    file_set_ids: { type: Array, suffix: 'ssim', value: ['abc123', 'def456'] },
    file_size: { type: String, suffix: 'lts' },
    identifier: { type: Array, suffix: 'ssim' },
    inscription: { type: Array, suffix: 'tesim' },
    keyword: { type: Array, suffix: 'tesim' },
    language: { type: Array, suffix: 'ssim' },
    language_label: { type: Array, suffix: 'ssim' },
    license: { type: Array, suffix: 'ssim' },
    local_identifier: { type: Array, key: 'identifier_local_ssim' },
    location: { type: Array, suffix: 'ssim' },
    location_label: { type: Array, suffix: 'tesim' },
    note: { type: Array, suffix: 'tesim' },
    organization: { type: Array, suffix: 'tesim' },
    original_checksum: { type: String, suffix: 'tesim' },
    original_item_extent: { type: Array, suffix: 'tesim' },
    physical_medium: { type: Array, suffix: 'tesim' },
    page_count: { type: String, suffix: 'tesim', value: '100' },
    permalink: { type: String, suffix: 'ss', value: 'http://hdl.handle.net/10385/test' },
    related_resource: { type: Array, suffix: 'tesim' },
    repository_location: { type: Array, suffix: 'ssim' },
    requested_by: { type: Array, suffix: 'ssim' },
    research_assistance: { type: Array, suffix: 'ssim' },
    resource_type: { type: Array, suffix: 'tesim' },
    rights_holder: { type: Array, suffix: 'tesim' },
    rights_statement: { type: Array, suffix: 'ssim' },
    rights_statement_label: { type: Array, suffix: 'ssim' },
    sort_date: {
      type: Date,
      suffix: 'dtsi',
      value: '2019-02-28T00:00:00Z',
      expected: Date.parse('2019-02-28T00:00:00Z')
    },
    source: { type: Array, suffix: 'tesim' },
    sponsor: { type: Array, suffix: 'tesim' },
    standard_identifier: { type: Array, key: 'identifier_standard_ssim' },
    subject: { type: Array, suffix: 'ssim' },
    subject_label: { type: Array, suffix: 'tesim' },
    subject_ocm: { type: Array, suffix: 'ssim' },
    subtitle: { type: Array, suffix: 'tesim' },
    title: { type: Array, suffix: 'tesim' },
    title_alternative: { type: Array, suffix: 'tesim' },
    citation_journal_title: { type: String, suffix: 'ss' },
    citation_volume: { type: String, suffix: 'ss' },
    citation_issue: { type: String, suffix: 'ss' },
    citation_firstpage: { type: String, suffix: 'ss' },
    citation_lastpage: { type: String, suffix: 'ss' }
  }.each_pair do |key, config|
    describe "##{key}" do
      subject { document.send(key) }

      let(:expected) do
        config[:expected] || (config[:type] == Array ? Array(value) : Array(value).first)
      end

      let(:doc_key) { config[:key] || "#{key}_#{config[:suffix]}" }
      let(:_value) { config[:value] || 'a test value' }
      let(:value) { doc_key.ends_with?('m') ? Array(_value) : _value }
      let(:metadata) { { doc_key => value } }

      it { is_expected.to be_a config[:type] }
      it { is_expected.to eq expected }
    end
  end

  describe '.field_semantics' do
    subject { described_class.field_semantics }

    it { is_expected.to be_a Hash }
  end

  describe '#to_param' do
    subject { document.to_param }

    context 'when the item is a collection' do
      let(:base_metadata) { { 'id' => 'abc123', 'has_model_ssim' => 'Collection' } }

      context 'when the collection has a slug' do
        let(:metadata) { base_metadata.merge('collection_slug_ssi' => 'a-cool-collection') }

        it { is_expected.to eq 'a-cool-collection' }
      end

      context 'when the collection does not have a slug' do
        let(:metadata) { base_metadata }

        it { is_expected.to eq 'abc123' }
      end
    end

    context 'default behavior' do
      let(:metadata) { { 'id' => 'abc123', 'has_model_ssim' => 'Publication' } }

      it { is_expected.to eq 'abc123' }
    end
  end

  describe '#visibility' do
    subject { document.visibility }

    context 'when an embargo_release_date is present' do
      let(:metadata) { { 'embargo_release_date_dtsi' => Time.zone.now.to_s } }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
    end

    context 'when a lease_expiration_date is present' do
      let(:metadata) { { 'lease_expiration_date_dtsi' => Time.zone.now.to_s } }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE }
    end

    context 'when public' do
      let(:metadata) { { Ability.read_group_field => [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC] } }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    context 'when authenticated' do
      let(:metadata) { { Ability.read_group_field => [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED] } }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
    end

    context 'when metadata only' do
      let(:metadata) { { Ability.discover_group_field => [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC] } }

      it { is_expected.to eq 'metadata' }
    end

    context 'default case (private)' do
      let(:metadata) { {} }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    end
  end
end
