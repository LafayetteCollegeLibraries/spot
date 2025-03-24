# frozen_string_literal: true
module Spot
  # An updated FileSetIndexer that does not index full-text content
  # (which has been moved to {PublicationIndexer})
  class FileSetIndexer < Hyrax::FileSetIndexer
    def generate_solr_document
      super.reject { |k, _v| k == 'all_text_timv' }.tap do |solr_document|
        solr_document['original_filenames_ssim'] = object.files.map(&:original_name)
        solr_document['transcript_name_ssi'] = object.transcript.nil? ? nil : object.transcript.original_name
        solr_document['stored_derivatives_ssim'] ||= []
      end
    end
  end
end
