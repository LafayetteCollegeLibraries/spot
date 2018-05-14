RSpec.shared_examples 'an indexable field' do
  before do
    sym = begin
            spl = solr_key.split('_')
            (spl - [spl.last]).join('_')
          end

    work.send(:"#{sym}=", value)
  end

  it 'indexes as expected' do
    expect(solr_doc).to have_key solr_key
    expect(solr_doc[solr_key]).to eq value
  end
end
