# frozen_string_literal: true
module Spot
  module Derivatives
    # Text extraction, ahem, extracted from Hyrax::FileSetDerivativesService.
    # Currently only being run for PDFs, but may be expanded to include
    # images if possible. This attaches a file to the file_set's with a type of
    # :extracted_text.
    #
    # @see https://github.com/samvera/hydra-derivatives/blob/v3.6.0/lib/hydra/derivatives/processors/full_text.rb
    # @see https://github.com/samvera/hydra-works/blob/v1.2.0/lib/hydra/works/services/add_file_to_file_set.rb
    #
    # @todo should we change the text extraction from hydra-derivatives' use
    #       of Solr's libraries to another service (Tesseract, AWS service?)
    # @todo revisit when we upgrade to Hyrax 3
    #
    class TextExtractionService < BaseDerivativeService
      # Extracted text is attached to the FileSet, which is deleted when the work is. No muss no fuss!
      #
      # @return [void]
      def cleanup_derivatives; end

      # @param [String] src_path
      # @return [void]
      def create_derivatives(src_path)
        return unless Hyrax.config.extract_full_text?
        Hydra::Derivatives::FullTextExtract.create(src_path,
                                                   outputs: [{ url: uri, container: "extracted_text" }])
      end

      # Only running text extraction on PDFs for the time being
      #
      # @return [true, false]
      def valid?
        pdf_mime_types.include? mime_type
      end
    end
  end
end
