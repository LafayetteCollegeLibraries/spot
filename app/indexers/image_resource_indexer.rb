# frozen_string_literal: true
class ImageResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:image_metadata)

  self.sortable_date_property = :date
end
