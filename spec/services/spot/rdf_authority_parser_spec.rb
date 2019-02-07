# frozen_string_literal: true
# borrows heavily from
# samvera/questioning_authority:spec/lib/services/rdf_authority_parser_spec.rb
RSpec.describe Spot::RDFAuthorityParser do
  let(:source) { [Rails.root.join('spec', 'fixtures', 'iso639-1-en.nt')] }
  let(:format) { :ntriples }
  let(:predicate) { ::RDF::Vocab::SKOS.prefLabel }
  let(:name) { 'languages' }
  let(:entry) { Qa::LocalAuthorityEntry.first }

  describe '#import_rdf' do
    before do
      described_class.import_rdf(name, source, format: format, predicate: predicate)
    end

    it 'creates the authority and authority entries' do
      expect(Qa::LocalAuthority.find_by(name: name)).not_to be_nil
      expect(Qa::LocalAuthorityEntry.count).to eq 1
      expect(entry.label).to eq 'English'
      expect(entry.uri).to eq 'http://id.loc.gov/vocabulary/iso639-1/en'
    end
  end
end
