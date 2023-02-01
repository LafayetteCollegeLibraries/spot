# frozen_string_literal: true
RSpec.describe Spot::Importers::CSV::WorkTypeMapper, feature: :csv_ingest_service do
  let(:mapper) { described_class.new(work_type: work_type) }
  let(:metadata) { {} }

  before do
    mapper.metadata = metadata
  end

  RSpec.shared_examples 'it maps metadata fields' do |opts|
    opts ||= {}
    opts[:fields] ||= []

    opts[:fields].each do |field|
      describe "##{field}" do
        subject { mapper.send(field) }

        let(:field) { field.to_s }
        let(:metadata) { { field.to_s => [value] } }
        let(:value) { 'value' }

        it { is_expected.to eq [value] }

        context 'when value is a URI' do
          let(:value) { 'http://id.worldcat.org/fast/1030904' }

          it { is_expected.to eq [RDF::URI(value)] }
        end

        context 'when value is nil' do
          let(:metadata) { { field.to_s => nil } }

          it { is_expected.to eq [] }
        end

        context 'when uri has a space' do
          let(:metadata) { { field.to_s => '  http://example.org' } }

          it { is_expected.to eq [RDF::URI('http://example.org')] }
        end
      end
    end
  end

  RSpec.shared_examples 'it maps Spot::CoreMetadata' do
    it_behaves_like 'it maps metadata fields', fields: %i[
      bibliographic_citation contributor creator description identifier
      keyword language location note physical_medium publisher
      related_resource resource_type rights_holder rights_statement
      source subject subtitle title_alternative
    ]
  end

  RSpec.shared_examples 'it maps Spot::InstitutionalMetadata' do
    it_behaves_like 'it maps metadata fields', fields: %i[academic_department division organization]
  end

  context 'with Publications' do
    let(:work_type) { Publication }

    it_behaves_like 'it maps Spot::CoreMetadata'
    it_behaves_like 'it maps Spot::InstitutionalMetadata'
    it_behaves_like 'it maps metadata fields', fields: %i[
      abstract date_issued date_available editor license
    ]
  end

  context 'with Images' do
    let(:work_type) { Image }

    it_behaves_like 'it maps Spot::CoreMetadata'
    it_behaves_like 'it maps metadata fields', fields: %i[
      date date_associated date_scope_note donor inscription original_item_extent
      repository_location requested_by research_assistance subject_ocm
    ]
  end

  context 'with StudentWorks' do
    let(:work_type) { StudentWork }

    it_behaves_like 'it maps Spot::CoreMetadata'
    it_behaves_like 'it maps Spot::InstitutionalMetadata'
    it_behaves_like 'it maps metadata fields', fields: %i[abstract access_note advisor date date_available]
  end
end
