# frozen_string_literal: true
RSpec.describe IndexesRightsStatements do
  subject(:doc) { FakeIndexer.new(publication).generate_solr_document }

  let(:publication) { Publication.new(rights_statement: [rights_statement]) }
  let(:rights_statement) { 'http://rightsstatements.org/vocab/NKC/1.0/' }

  before do
    class FakeIndexer < ActiveFedora::IndexingService
      include IndexesRightsStatements
    end
  end

  after do
    Object.send(:remove_const, :FakeIndexer)
  end

  describe '#generate_solr_document' do
    it { is_expected.to include 'rights_statement_ssim' }
    it { is_expected.to include 'rights_statement_label_ssim' }

    it 'stores the uri under `rights_statement_ssim`' do
      expect(doc['rights_statement_ssim']).to eq [rights_statement]
    end

    it 'stores the label under `rights_statement_label_ssim`' do
      expect(doc['rights_statement_label_ssim']).to eq ['No Known Copyright']
    end
  end
end
