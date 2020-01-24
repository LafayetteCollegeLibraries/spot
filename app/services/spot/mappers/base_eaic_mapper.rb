# frozen_string_literal: true

module Spot::Mappers
  class BaseEaicMapper < BaseMapper
    include LanguageTaggedTitles

    def identifier
      [eaic_id_from_title]
    end

    def location
      convert_uri_strings(merge_fields('coverage.location', 'coverage.location.country'))
    end

    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end

    private

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
