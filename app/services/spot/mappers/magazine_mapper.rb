# frozen_string_literal: true

module Spot::Mappers
  class MagazineMapper < BaseHashMapper
    include ShortDateConversion
    include NestedAttributes

    self.fields_map = {
      creator: 'NamePart_DisplayForm_PersonalAuthor',
      publisher: 'OriginInfoPublisher',
      source: 'RelatedItemHost_1_TitleInfoTitle',
    }.freeze

    # Darlingtonia's Mapper pattern relies on this returned array to
    # determine what fields to include on the object. When a method is
    # missing, it uses the <code>fields</code> Hash to find the
    # related key for the raw <code>metadata</code> Hash.
    #
    # @return [Array<Symbol>]
    def fields
      super + %i[
        based_near_attributes
        date_issued
        description
        identifier
        related_resource
        resource_type
        subtitle
        title
      ]
    end

    # @todo return to this
    # @return [Array<String>]
    def based_near_attributes
      nested_attributes_hash_for('OriginInfoPlaceTerm') do |original_value|
        # downcasing to save us from ourselves: 'Easton, Pa' vs 'Easton, PA'
        case original_value.downcase
        when 'easton, pa'
          'http://sws.geonames.org/5188140/'
        else
          Rails.logger.warn("No URI provided for #{original_value}; skipping")
          ''
        end
      end
    end

    # Despite being labeled as 'ISO8601', legacy magazine dates are in
    # mm/dd/yy format. The 'PublicationSequence' field has 1930 listed
    # as 1, so we can infer that '00', for example, is 2000 and not 1900.
    #
    # @return [Array<String>]
    def date_issued
      metadata['PartDate_ISO8601'].map do |raw|
        short_date_to_iso(raw, century_threshold: 30)
      end
    end

    # Maps magazine descriptions to English-tagged RDF literals
    #
    # @return [Array<RDF::Literal>]
    def description
      metadata['TitleInfoPartNumber'].reject(&:blank?).map do |desc|
        RDF::Literal(desc, language: :en)
      end
    end

    # Creates a local identifier using the 'Publication Sequence' number
    #
    # @return [Array<String>]
    def identifier
      metadata['PublicationSequence'].map { |num| "lafayette_magazine:#{num}" }
    end

    # Maybe a little clever for its own good, but it gathers the unique
    # values across three metadata fields and strips out any blanks.
    #
    # @return [Array<String>]
    def related_resource
      (
        Array(metadata['TitleInfoPartNumber']) |
        Array(metadata['RelatedItemHost_1_TitleInfoTitle']) |
        Array(metadata['RelatedItemHost_2_TitleInfoTitle'])
      ).compact
    end

    # All magazines are mapped to the 'Journal' resource_type
    #
    # @return [Array<String>]
    def resource_type
      ['Journal']
    end

    # Maps subtitles to English-tagged RDF literals
    #
    # @return [Array<RDF::Literal>]
    def subtitle
      metadata['TitleInfoSubtitle'].reject(&:blank?).map do |subtitle|
        RDF::Literal(subtitle, language: :en)
      end
    end

    # Our joined titles mapped to RDF literals (tagged English)
    #
    # @return [Array<RDF::Literal>]
    def title
      parsed_title.map { |title| RDF::Literal(title, language: :en) }
    end

    private

    # The display title is a combination of the `TitleInfoNonSort`,
    # `TitleInfoTitle`, and `PartDate_NaturalLanguage` fields.
    #
    # @return [Array<String>]
    def parsed_title
      non_sort = metadata['TitleInfoNonSort'].first
      info_title = metadata['TitleInfoTitle'].first
      date = metadata['PartDate_NaturalLanguage']

      title = "#{non_sort} #{info_title}".strip

      # date could be nil or '' or []
      return [title] if date.blank? || date.empty?

      ["#{title} (#{date.first})"]
    end
  end
end
