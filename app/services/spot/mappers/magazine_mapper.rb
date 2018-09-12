# frozen_string_literal: true

module Spot::Mappers
  class MagazineMapper < HashMapper
    include ShortDateConversion

    self.fields_map = {
      creator: 'NamePart_DisplayForm_PersonalAuthor',
      description: 'TitleInfoPartNumber',
      publisher: 'OriginInfoPublisher',
      source: 'RelatedItemHost_1_TitleInfoTitle',
      subtitle: 'TitleInfoSubtitle'
    }.freeze

    # Darlingtonia's Mapper pattern relies on this returned array to
    # determine what fields to include on the object. When a method is
    # missing, it uses the <code>fields</code> Hash to find the
    # related key for the raw <code>metadata</code> Hash.
    #
    # @return [Array<Symbol>]
    def fields
      super + %i[
        based_near
        date_issued
        resource_type
        title
      ]
    end

    # @return [Array<RDF::URI,String>]
    def based_near
      metadata['OriginInfoPlaceTerm'].map do |place|
        if place == 'Easton, PA'
          RDF::URI('http://sws.geonames.org/5188140/')
        else
          place
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

    # All magazines are mapped to the 'Journal' resource_type
    #
    # @return [Array<String>]
    def resource_type
      ['Journal']
    end

    # The display title is a combination of the `TitleInfoNonSort`,
    # `TitleInfoTitle`, and `PartDate_NaturalLanguage` fields.
    #
    # @return [Array<String>]
    def title
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
