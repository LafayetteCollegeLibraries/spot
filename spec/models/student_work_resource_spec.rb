# frozen_string_literal: true
RSpec.describe StudentWorkResource, valkyrization: true do
  subject(:resource) { described_class.new }

  describe 'metadata properties' do
    # @see spec/support/shared_examples/models/common_metadata_fields.rb
    it_behaves_like 'it has base metadata fields'
    it_behaves_like 'it has core metadata fields'

    # student work metadata
    it 'has abstracts' do
      expect { resource.abstract = ['a brief description'] }
        .to change { resource.abstract }
        .to contain_exactly('a brief description')
    end

    it 'has access_notes' do
      expect { resource.access_note = ['admin access only'] }
        .to change { resource.access_note }
        .to contain_exactly('admin access only')
    end

    it 'has advisors' do
      expect { resource.advisor = ['Professor A', 'Professor B.'] }
        .to change { resource.advisor }
        .to contain_exactly('Professor A', 'Professor B.')
    end

    it 'has dates' do
      expect { resource.date = ['2026-05'] }
        .to change { resource.date }
        .to contain_exactly('2026-05')
    end

    it 'has date_availables' do
      expect { resource.date_available = ['2026-06-01'] }
        .to change { resource.date_available }
        .to contain_exactly('2026-06-01')
    end
  end
end
