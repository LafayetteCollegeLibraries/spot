# frozen_string_literal: true
class ImageResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:image_metadata)

  self.years_encompassed_fields = [:date, :date_associated]
end
