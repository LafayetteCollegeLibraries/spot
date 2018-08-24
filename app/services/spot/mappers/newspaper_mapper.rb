# frozen_string_literal: true

module Spot::Mappers
  class NewspaperMapper < ::Darlingtonia::HashMapper
    FIELDS_MAP = {

    }.freeze

    def fields
      FIELDS_MAP.keys + %i[
        date_issued
      ]
    end

    # Preferring values from `date.dateOther` and falling back to `date.dateIssued`
    # where necessary.
    #
    # @return Array[<String>] the date in YYYY-MM-DD format
    def date_issued
      raw_value = metadata['date.dateOther'] unless metadata['date.dateOther'].empty?
      raw_value ||= metadata['date.dateIssued']

      return [] unless raw_value

      parsed = Date.parse(raw_value)
      Array(parsed.strftime('%Y-%m-%d'))
    end
  end
end
