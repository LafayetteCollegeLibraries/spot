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
      Array.wrap(metadata['journal_issns'])
           .map { |v| "issn:#{v}" }
           .push("doi:#{metadata['doi']}")
    end

    # @return [String, nil]
    def license
      Array.wrap(metadata.dig('best_oa_location', 'license'))
    end

    # @return [Array<String>]
    def representative_file
      Array.wrap(metadata.dig('best_oa_location', 'url_for_pdf'))
    end

  private

    # Wraps the original response in an array, since all of those fields are multi-valued
    #
    # @param [String, Symbol] name The field name
    # @return [Array<any>]
    def map_field(name)
      Array.wrap(super(name))
    end
  end
end
