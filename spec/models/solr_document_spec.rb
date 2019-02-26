# frozen_string_literal: true
RSpec.describe SolrDocument do
  let(:document) { described_class.new(metadata) }

  {
    abstract: { type: Array, suffix: 'tesim' },
    academic_department: { type: Array, suffix: 'tesim' },
    admin_set: { type: String, suffix: 'tesim' },
    bibliographic_citation: { type: Array, suffix: 'tesim' },
    contributor: { type: Array, suffix: 'tesim' },
    date_available: { type: Array, suffix: 'ssim' },
    date_issued: { type: Array, suffix: 'ssim' },
    depositor: { type: String, suffix: 'ssim' },
    description: { type: Array, suffix: 'tesim' },
    division: { type: Array, suffix: 'tesim' },
    editor: { type: Array, suffix: 'tesim' },
    identifier: { type: Array, suffix: 'ssim' },
    keyword: { type: Array, suffix: 'tesim' },
    language: { type: Array, suffix: 'ssim' },
    language_label: { type: Array, suffix: 'ssim' },
    license: { type: Array, suffix: 'ssim' },
    organization: { type: Array, suffix: 'tesim' },
    physical_medium: { type: Array, suffix: 'tesim' },
    place: { type: Array, suffix: 'ssim' },
    place_label: { type: Array, suffix: 'ssim' },
    related_resource: { type: Array, suffix: 'ssim' },
    resource_type: { type: Array, suffix: 'tesim' },
    rights_statement: { type: Array, suffix: 'ssim' },
    rights_statement_label: { type: Array, suffix: 'ssim' },
    source: { type: Array, suffix: 'tesim' },
    sponsor: { type: Array, suffix: 'tesim' },
    subject: { type: Array, suffix: 'tesim' },
    subtitle: { type: Array, suffix: 'tesim' },
    title: { type: Array, suffix: 'tesim' },
    title_alternative: { type: Array, suffix: 'tesim' }
  }.each_pair do |key, config|
    describe "##{key}" do
      subject { document.send(key) }

      let(:_value) { config[:value] || 'a test value' }
      let(:value) { config[:suffix].ends_with?('m') ? Array(_value) : value }
      let(:expected) { config[:type] == Array ? Array(value) : Array(value).first }
      let(:metadata) { { "#{key}_#{config[:suffix]}" => value } }

      it { is_expected.to be_a config[:type] }
      it { is_expected.to eq expected }
    end
  end
end
