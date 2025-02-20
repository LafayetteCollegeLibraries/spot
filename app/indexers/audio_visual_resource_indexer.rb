# frozen_string_literal: true
class AudioVisualResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:audio_visual_metadata)

  self.sortable_date_property = :date
end
