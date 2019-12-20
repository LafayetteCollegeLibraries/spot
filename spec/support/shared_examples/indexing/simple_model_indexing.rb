# frozen_string_literal: true
# this is expecting to be called within a block like:
#
#   RSpec.describe ImageIndexer do
#     subject(:solr_doc) { indexer.generate_solr_document }
#
#     let(:work) { build(:image) }
#     let(:indexer) { described_class.new(work) }
#
#     describe 'subject' do
#       let(:work_method) { :subject }
#       let(:solr_fields) { %w[subject_tesim subject_sim] }
#       it_behaves_like 'simple model indexing'
#     end
#   end

RSpec.shared_examples 'simple model indexing' do
  it { is_expected.to include(*solr_fields) }

  it 'adds the work value to each field' do
    solr_fields.each do |field|
      expect(solr_doc[field]).to match_array work.send(work_method.to_sym)
    end
  end
end
