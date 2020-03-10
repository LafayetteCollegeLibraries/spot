# frozen_string_literal: true
module Spot::Mappers
  # A starting point for mapping collections in the East Asian Image Collection (EAIC)
  # to the Image model. The methods defined are a common denomenator base set of
  # mappings. Just inheriting this mapper will not do anything, you'll need to add
  # the methods you'd like to use to your mapper's +#fields+ array.
  #
  # @example
  #   module Spot::Mappers
  #     class PostcardCollectionMapper < BaseEaicMapper
  #       def fields
  #         super + [:date, :description, :identifier, :title, :title_alternative]
  #       end
  #     end
  #   end
  #
  class BaseEaicMapper < BaseMapper
    include LanguageTaggedTitles

    # 'date.artifact.lower' and 'date.artifact.upper' fields concatted into
    # an EDTF date string. When both fields are available, a range object
    # is returned (eg. '1986/2020'), otherwise just a single date will be returned.
    #
    # @return [Array<String>]
    def date
      edtf_ranges_for('date.artifact.lower', 'date.artifact.upper')
    end

    def date_associated
      image_date_ranges
    end

    # Returns the values of 'description.critical' as RDF::Literal objects.
    #
    # @return [Array<RDF::Literal>]
    def description
      field_to_tagged_literals('description.critical', :en)
    end

    # Extracts an EAIC style ID from a title field (default is "title.english")
    #
    # @example
    #   metadata['title.english']
    #   # => ["[ww0032] [Ami pottery-making]"]
    #
    #   identifier
    #   # => ['eaic:ww0032']
    #
    def identifier
      [eaic_id_from_title]
    end

    # Grabs and converts location values in 'coverage.location' and 'coverage.location.country'
    # to RDF::URI objects (where applicable). Non-URIs are retained as strings.
    #
    # @return [Array<RDF::URI, String>]
    def location
      convert_uri_strings(merge_fields('coverage.location', 'coverage.location.country'))
    end

    # The backs of postcards will always have a suffix after the initial filename
    # (ex. 'lc-spcol-pacwar-postcards-0009.tif' and 'lc-spcol-pacwar-postcards-0009b.tif',
    # or 'lc-spcol-woodsworth-images-0043.tif' and 'lc-spcol-woodsworth-images-0043-back.tif').
    # To ensure that both forms sort properly (the character code for '-' (45) is lower than
    # that of '.'(46)), we'll sort based on the filenames without extensions.
    #
    # @return [Array<String>]
    def representative_files
      super.sort { |a, b| File.basename(a, '.*') <=> File.basename(b, '.*') }
    end
    alias representative_file representative_files

    # Grabs and convert values in 'rights.statement' to RDF::URI objects
    # (where applicable). Non-URIs are retained as strings.
    #
    # @return [Array<RDF::URI, String>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end

    # Grabs and convert values in 'subject' to RDF::URI objects
    # (where applicable). Non-URIs are retained as strings.
    #
    # @return [Array<RDF::URI, String>]
    def subject
      convert_uri_strings(metadata.fetch('subject', []))
    end

    private

      # @return [Array<String>]
      def image_date_ranges
        edtf_ranges_for('date.image.lower', 'date.image.upper')
      end

      # @param [String] field
      # @return [String, nil]
      def eaic_id_from_title(field = 'title.english')
        values = metadata.fetch(field, [])
        return if values.empty?

        match_data = values.first.match(/^\[(\w+\d+)\]/)
        return if match_data.nil?

        Spot::Identifier.new('eaic', match_data[1]).to_s
      end

      # @param [String] start_date_field
      # @param [String] end_date_field
      # @return [String] parsed EDTF range string
      def edtf_ranges_for(start_date_field, end_date_field)
        start_dates = metadata.fetch(start_date_field, [])
        end_dates = metadata.fetch(end_date_field, [])

        # Array#zip will return an empty array if the target (start_dates) is empty
        start_dates.fill(0, end_dates.size) { nil } if start_dates.empty?

        start_dates.zip(end_dates).map do |(start_date, end_date)|
          # EDTF date ranges are "#{start_date}/#{end_date}"
          [start_date, end_date].reject(&:blank?).join('/')
        end
      end
  end
end
