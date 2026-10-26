# frozen_string_literal: true
class AudioVisualResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:audio_visual_metadata)

  self.sortable_date_field = :date
  self.years_encompassed_fields = [:date, :date_associated]
end
