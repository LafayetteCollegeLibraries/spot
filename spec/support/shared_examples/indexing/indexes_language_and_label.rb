# frozen_string_literal: true
RSpec.shared_examples 'it indexes ISO language and label' do
  describe '#language' do
    # rubocop:disable RSpec/InstanceVariable
    before do
      @previous_language = work.language
      work.language = languages
    end

    after do
      work.language = @previous_language
    end
    # rubocop:enable RSpec/InstanceVariable

    let(:languages) { ['en', 'ja', 'nope'] }
    let(:labels) { languages.map { |lang| Spot::ISO6391.label_for(lang) }

    it 'stores the raw values as _ssim' do
      expect(solr_doc['language_ssim']).to contain_exactly(*languages)
    end

    it 'stores the translated labels as _label_ssim' do
      expect(solr_doc['language_label_ssim']).to contain_exactly(*labels)
    end
  end
end
