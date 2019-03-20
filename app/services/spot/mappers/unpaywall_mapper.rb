# frozen_string_literal: true
#
# Metadata mapper for API v2 responses from unpaywall.org.
# See {Spot::Mappers::BaseMapper} for usage information.
module Spot::Mappers
  class UnpaywallMapper < BaseMapper
    self.fields_map = {
      date_issued: 'published_date',
      publisher: 'publisher',
      source: 'journal_name',
      title: 'title'
    }

    # @return [Array<Symbol>]
    def fields
      super + %i[
        contributor
        identifier
        license
        source
      ]
    end

    # @return [Array<String>]
    def contributor
      Array.wrap(metadata['z_authors']).map do |author|
        [author['family'], author['given']].join(', ')
      end
    end

    # @return [Array<String>]
    def identifier
      Array.wrap(metadata['journal_issns']).map { |v| "issn:#{v}" } + ["doi:#{metadata['doi']}"]
    end

    # @return [String, nil]
    def license
      best_oa_location && best_oa_location['license']
    end

    def representative_files
      return [] if best_oa_location.nil? || url_for_pdf.nil?
      [url_for_pdf]
    end

    # @return [String, nil]
    def source
      metadata['publisher']
    end

    private

      # @return [Hash<String => String>, nil]
      def best_oa_location
        metadata['best_oa_location']
      end

      # @return [String, nil]
      def url_for_pdf
        metadata['url_for_pdf']
      end
  end
end
