# frozen_string_literal: true
module Spot::Mappers
  class WarCasualtiesMapper < BaseEaicMapper
    self.fields_map = {
      keyword: 'relation.IsPartOf',
      repository_location: 'publisher.digital',
      resource_type: 'resource.type',
      source: 'format.analog'
    }

    def fields
      super + [
        :date,
        :description,
        :location,
        :subtitle,

        :rights_statement,
        :subject
      ]
    end

    # @return [Array<String>]
    def date
      edtf_ranges_for('date.birth.search', 'date.death.search')
    end

    # @return [Array<RDF::Literal>]
    def description
      field_to_tagged_literals('description.narrative', :en)
    end

    # @return [Array<RDF::URI>]
    def location
      convert_uri_strings(merge_fields('coverage.place.birth', 'coverage.place.death'))
    end

    # @return [Array<String>]
    def subtitle
      branch_rank = [metadata['description.military.branch'], metadata['description.military.rank']].compact.join(' ')
      military_title = [branch_rank, metadata['contributor.military.unit']].compact.join(', ')

      [military_title, metadata['description.class']].flatten.compact
    end

    # need to override BaseEaicMapper#title
    #
    # @return [Array<String>]
    def title
      Array.wrap(metadata['title.name'])
    end
  end
end
