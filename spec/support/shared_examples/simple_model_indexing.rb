# this is expecting to be called within a block like:
#
#   RSpec.describe ImageIndexer do
#     subject(:solr_doc) { indexer.generate_solr_document }
#
#     let(:work) { build(:image) }
#     let(:indexer) { described_class.new(work) }
#
#     describe 'subject' do
#       let(:fields) { %w[subject_tesim subject_sim] }
#       it_behaves_like 'simple model indexing'
#     end
#   end

RSpec.shared_examples 'simple model indexing' do
  it { is_expected.to include *fields }
  it 'adds the work value to each field' do
    fields.each do |field|
      method = field.sub(/_[a-z]+$/, '').to_sym
      expect(subject[field]).to match_array work.send(method)
    end
  end
end
