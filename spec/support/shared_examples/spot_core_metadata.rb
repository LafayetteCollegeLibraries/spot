# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::CoreMetadata' do
  subject { described_class.new }

  [
    [:bibliographic_citation, RDF::Vocab::DC.bibliographicCitation],
    [:contributor,            RDF::Vocab::DC11.contributor],
    [:creator,                RDF::Vocab::DC11.creator],
    [:description,            RDF::Vocab::DC11.description],
    [:identifier,             RDF::Vocab::DC.identifier],
    [:keyword,                RDF::Vocab::SCHEMA.keywords],
    [:language,               RDF::Vocab::DC11.language],
    [:location,               RDF::Vocab::DC.spatial],
    [:note,                   RDF::Vocab::SKOS.note],
    [:physical_medium,        RDF::Vocab::DC.PhysicalMedium],
    [:publisher,              RDF::Vocab::DC11.publisher],
    [:related_resource,       RDF::RDFS.seeAlso],
    [:resource_type,          RDF::Vocab::DC.type],
    [:rights_holder,          RDF::Vocab::DC.rightsHolder],
    [:rights_statement,       RDF::Vocab::EDM.rights],
    [:source,                 RDF::Vocab::DC.source],
    [:source_identifier,      RDF::URI('http://ldr.lafayette.edu/ns#source_identifier')],
    [:subject,                RDF::Vocab::DC11.subject],
    [:subtitle,               RDF::URI.new('http://purl.org/spar/doco/Subtitle')],
    [:title_alternative,      RDF::Vocab::DC.alternative]
  ].each do |(property, predicate)|
    it { is_expected.to have_editable_property(property).with_predicate(predicate) }
  end

  describe 'runs ensure_source_identifier! after :create' do
    subject(:created_work) { described_class.create!(metadata) }

    let(:base_metadata) do
      {
        title: ["Sourced Work #{described_class.name}"],
        rights_statement: ['http://creativecommons.org/publicdomain/mark/1.0/'],
        resource_type: ['Other']
      }
    end


    let(:publication_metadata) { base_metadata.merge(date_issued: ['2022-11-28']) }
    let(:image_metadata) { base_metadata.dup }
    let(:student_work_metadata) { base_metadata.dup }

    let(:metadata) { send(metadata_variable) }
    let(:metadata_variable) { described_class.name.underscore + "_metadata" }

    context 'when a source_identifier is provided' do
      let(:source_identifier) { ['ldr:ingest:abc123'] }
      let(:metadata) { send(metadata_variable).merge(source_identifier: source_identifier) }

      it 'uses the provided identifier' do
        expect(created_work.source_identifier).to eq source_identifier
      end
    end

    context 'when a source_identifier is not provided' do
      it 'creates one with the minted work id' do
        expect(created_work.source_identifier).to eq ["ldr:#{created_work.id}"]
      end
    end
  end
end
