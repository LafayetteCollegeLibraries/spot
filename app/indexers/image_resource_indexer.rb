# frozen_string_literal: true
#
# Indexer for ImageResource objects.
#
# @todo add handling for years_encompassed_iim
class ImageResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:image_metadata)

  self.sortable_date_property = :date
end
