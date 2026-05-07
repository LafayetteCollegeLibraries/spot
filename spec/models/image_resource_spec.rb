# frozen_string_literal: true
RSpec.describe ImageResource, valkyrization: true do
  subject(:resource) { described_class.new }

  describe 'metadata properties' do
    # @see spec/support/shared_examples/models/common_metadata_fields.rb
    it_behaves_like 'it has base metadata fields'
    it_behaves_like 'it has core metadata fields'

    # image_metadata
    it 'has dates' do
      expect { resource.date = ['2026-05', '2026-05-07'] }
        .to change { resource.date }
        .to contain_exactly('2026-05', '2026-05-07')
    end

    it 'has date_associateds' do
      expect { resource.date_associated = ['2026-05-07', '2026-05-08'] }
        .to change { resource.date_associated }
        .to contain_exactly('2026-05-07', '2026-05-08')
    end

    it 'has date_scope_notes' do
      expect { resource.date_scope_note = ['a big day'] }
        .to change { resource.date_scope_note }
        .to contain_exactly('a big day')
    end

    it 'has donors' do
      expect { resource.donor = ['alumnus'] }
        .to change { resource.donor }
        .to contain_exactly('alumnus')
    end

    it 'has inscriptions' do
      expect { resource.inscription = ['a small note'] }
        .to change { resource.inscription }
        .to contain_exactly('a small note')
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

    it 'has requested_bys' do
      expect { resource.requested_by = ['student a', 'student b'] }
        .to change { resource.requested_by }
        .to contain_exactly('student a', 'student b')
    end

    it 'has research_assistance' do
      expect { resource.research_assistance = ['student c', 'student d'] }
        .to change { resource.research_assistance }
        .to contain_exactly('student c', 'student d')
    end

    it 'has subject_ocms' do
      expect { resource.subject_ocm = ['000 VALUE'] }
        .to change { resource.subject_ocm }
        .to contain_exactly('000 VALUE')
    end

  end
end