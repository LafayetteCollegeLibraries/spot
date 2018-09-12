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

    # Magazines contain a field of 'TitleInfoNonSort' which usually stores
    # the word 'The', but is also sometimes empty. We want to merge these
    # fields and ensure there is no whitespace remaining.
    #
    # This is written a little convolutedly because we want to cover the
    # possibility of multiple titles being present (which I'm like 99% sure
    # will never happen). So we'll merge both of the title fields with
    # `Array#zip` and joining the fields via `Array#join`. We need to start
    # with 'TitleInfoTitle' because that field is always expected to be present,
    # whereas 'TitleInfoNonSort' is sometimes absent (and `Array#zip` will
    # return an empty array if the source array is empty). To fix this, we'll
    # run `Array#reverse` before joining the fields.
    #
    # @return [Array<String>]
    def title
      metadata['TitleInfoTitle']
        .zip(metadata['TitleInfoNonSort'])
        .map { |pair| pair.reverse.join(' ').strip }
    end
  end
end
