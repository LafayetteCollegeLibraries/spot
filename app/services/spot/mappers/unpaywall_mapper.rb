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
      best_oa_location && Array.wrap(best_oa_location['license'])
    end

    # @return [Array<String>]
    def representative_file
      url_for_pdf || []
    end

    # @return [String, nil]
    def source
      Array.wrap(metadata['publisher'])
    end

    private

      # @return [Hash<String => String>, nil]
      def best_oa_location
        metadata['best_oa_location']
      end

      # Wraps the original response in an array, since all of those fields are multi-valued
      #
      # @param [String, Symbol] name The field name
      # @return [Array<any>]
      def map_field(name)
        Array.wrap(super(name))
      end

      # @return [String, nil]
      def url_for_pdf
        best_oa_location && Array.wrap(best_oa_location['url_for_pdf'])
      end
  end
end
