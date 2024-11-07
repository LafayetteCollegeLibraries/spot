# frozen-string_literal: true
class PublicationResourceIndexer < BaseResourceIndexer
  include Hyrax::Indexer(:institutional_metadata)
  include Hyrax::Indexer(:publication_metadata)

  include IndexesSeasonalDates

  self.sortable_date_property = :date_issued
end
