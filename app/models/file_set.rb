# frozen_string_literal: true
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior

  # using our own FileSetIndexer that doesn't index full-text content
  self.indexer = Spot::FileSetIndexer
end
