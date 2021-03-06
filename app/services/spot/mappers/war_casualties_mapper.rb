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
        :rights_statement,
        :subtitle,

        :subject,
        :title
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

    # @return [Array<RDF::URI>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end

    # @return [Array<String>]
    def subtitle
      branch = Array.wrap(metadata['description.military.branch']).first
      rank = Array.wrap(metadata['description.military.rank']).first
      unit = Array.wrap(metadata['contributor.military.unit']).first
      graduating_class = Array.wrap(metadata['description.class']).first

      branch_rank = [branch, rank].compact.join(' ')
      military_title = [branch_rank, unit].compact.join(', ')

      [military_title, graduating_class].reject(&:blank?)
    end

    # need to override BaseEaicMapper#title
    #
    # @return [Array<String>]
    def title
      Array.wrap(metadata['title.name'])
    end
  end
end
