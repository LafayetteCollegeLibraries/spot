# frozen_string_literal: true

module Spot::Mappers
  class MagazineMapper < ::Darlingtonia::HashMapper
    FIELDS_MAP = {
      publisher: 'OriginInfoPublisher',
      source: 'RelatedItemHost_1_TitleInfoTitle',
      subtitle: 'TitleInfoSubtitle'
    }.freeze

    # Darlingtonia's Mapper pattern relies on this returned array to
    # determine what fields to include on the object. When a method is
    # missing, it uses the <code>FIELDS_MAP</code> Hash to find the
    # related key for the raw <code>metadata</code> Hash.
    #
    # @return [Array<Symbol>]
    def fields
      FIELDS_MAP.keys + %i[
        date_issued
        resource_type
        title
      ]
    end

    # @todo Move to a concern/mixin
    # @param [String] name The field name
    # @return [any]
    def map_field(name)
      metadata[FIELDS_MAP[name.to_sym]]
    end

    # Despite being labeled as 'ISO8601', legacy magazine dates are in
    # mm/dd/yy format. The 'PublicationSequence' field has 1930 listed
    # as 1, so we can infer that '00', for example, is 2000 and not 1900.
    #
    # @return [String]
    def date_issued
      metadata['PartDate_ISO8601'].split(';').map do |raw|
        m = raw.match(%r[(?<month>\d{1,2})/(?<day>\d{1,2})/(?<year>\d{2})])

        return raw if m.nil?

        year_prefix = m[:year].to_i < 30 ? '20' : '19'
        padded_year = m[:year].rjust(2, '0')

        year = "#{year_prefix}#{padded_year}"
        month = m[:month].rjust(2, '0')
        day = m[:day].rjust(2, '0')

        "#{year}-#{month}-#{day}"
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
