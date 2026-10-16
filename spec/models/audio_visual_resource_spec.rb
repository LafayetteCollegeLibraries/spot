# frozen_string_literal: true
RSpec.describe AudioVisualResource, valkyrization: true do
  subject(:resource) { described_class.new }

  describe 'metadata properties' do
    # @see spec/support/shared_examples/models/common_metadata_fields.rb
    it_behaves_like 'it has base metadata fields'
    it_behaves_like 'it has core metadata fields'

    # audio visual metadata
    it 'has barcodes' do
      expect { resource.barcode = ['00000000'] }
        .to change { resource.barcode }
        .to contain_exactly('00000000')
    end

    it 'has dates' do
      expect { resource.date = ['2026-05-07'] }
        .to change { resource.date }
        .to contain_exactly('2026-05-07')
    end

    it 'has date_associateds' do
      expect { resource.date_associated = ['2026-05-07'] }
        .to change { resource.date_associated }
        .to contain_exactly('2026-05-07')
    end

    it 'has inscriptions' do
      expect { resource.inscription = ['inscribed text', 'another note'] }
        .to change { resource.inscription }
        .to contain_exactly('inscribed text', 'another note')
    end

    it 'has original_item_extents' do
      expect { resource.original_item_extent = ['9cm', '6oz'] }
        .to change { resource.original_item_extent }
        .to contain_exactly('9cm', '6oz')
    end

    it 'has repository_locations' do
      expect { resource.repository_location = ['in the back room'] }
        .to change { resource.repository_location }
        .to contain_exactly('in the back room')
    end

    it 'has research_assistance' do
      expect { resource.research_assistance = ['Student A.', 'Student B.'] }
        .to change { resource.research_assistance }
        .to contain_exactly('Student A.', 'Student B.')
    end

    it 'has provenances' do
      expect { resource.provenance = ['found it at a yard sale'] }
        .to change { resource.provenance }
        .to contain_exactly('found it at a yard sale')
    end
  end
end
