# frozen_string_literal: true
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
  include ::Spot::MetadataOnlyVisibility

  # using our own FileSetIndexer that doesn't index full-text content
  self.indexer = Spot::FileSetIndexer

  # An identifier that links this record to a Bulkrax import/export record.
  # For objects created within the Hyrax UI (_not_ Bulkrax), this will be
  # filled with a default value of ["ldr:#{work.id}"]
  #
  # @todo find a better predicate for this field
  property :source_identifier, predicate: ::RDF::URI('http://ldr.lafayette.edu/ns#source_identifier') do |index|
    index.as :symbol, :stored_searchable
  end
end
