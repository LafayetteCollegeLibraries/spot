# frozen_string_literal: true

module Spot::Mappers
  class BaseEaicMapper < BaseMapper
    include LanguageTaggedTitles

    private

      # @param [String] start_date_field
      # @param [String] end_date_field
      # @return [String] parsed EDTF range string
      def etdf_range_for(start_date_field, end_date_field)
        start_date = metadata.fetch(start_date_field, '')
        end_date = metadata.fetch(end_date_field, '')

        Date.edtf([start_date, end_date].reject(&:blank?).join('/')).to_s
      end

      # Helper method to group the values for multiple fields into one place.
      #
      # @param [Array<String>] *names field names to merge
      # @return [Array<String>]
      def merge_fields(*names)
        names.map { |name| metadata[name] }.flatten.compact
      end
  end
end
