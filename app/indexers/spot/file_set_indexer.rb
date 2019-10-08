# frozen_string_literal: true
module Spot
  # An updated FileSetIndexer that does not index full-text content
  # (which has been moved to {PublicationIndexer})
  class FileSetIndexer < Hyrax::FileSetIndexer
    def generate_solr_document
      super.reject { |k, _v| k == 'all_text_timv' }
    end
  end
end
