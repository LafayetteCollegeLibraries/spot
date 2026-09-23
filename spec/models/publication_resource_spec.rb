# frozen_string_literal: true
RSpec.describe PublicationResource, valkyrization: true do
  subject(:resource) { described_class.new }

  describe 'metadata properties' do
    # @see spec/support/shared_examples/models/common_metadata_fields.rb
    it_behaves_like 'it has base metadata fields'
    it_behaves_like 'it has core metadata fields'
    it_behaves_like 'it has institutional metadata fields'

    describe 'publication metadata' do
      it 'has abstracts' do
        expect { resource.abstract = ['Short description'] }
          .to change { resource.abstract }
          .to eq ['Short description']
      end

      it 'has dates available' do
        expect { resource.date_available = ['2026-05-07'] }
          .to change { resource.date_available }
          .to eq ['2026-05-07']
      end

      it 'has dates issued' do
        expect { resource.date_issued = ['2026-05-07'] }
          .to change { resource.date_issued }
          .to eq ['2026-05-07']
      end

      it 'has an editor' do
        expect { resource.editor = ['Ed. 1', 'Ed.2 '] }
          .to change { resource.editor }
          .to eq ['Ed. 1', 'Ed.2 ']
      end

      it 'has an license' do
        expect { resource.abstract = ['Some licensing info'] }
          .to change { resource.abstract }
          .to eq ['Some licensing info']
      end
    end
  end
end
