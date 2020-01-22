# frozen_string_literal: true

module Spot::Mappers
  class BaseEaicMapper < BaseMapper
    include LanguageTaggedTitles

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

        start_dates.zip(end_dates).map do |(start_date, end_date)|
          Date.edtf([start_date, end_date].reject(&:blank?).join('/')).to_s
        end
      end
  end
end
