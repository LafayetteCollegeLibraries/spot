# frozen_string_literal: true
module Spot::Importers::CSV
  # Validator for CSV files to ensure that if the file contains a "work_type" field,
  # the values for that field can all be interpreted as valid work types.
  class WorkTypeValidator < ::Darlingtonia::Validator
    def self.valid?(value)
      Hyrax.config.curation_concerns.include?(value.to_s.singularize.camelize.constantize)
    rescue NameError
      false
    end

    def validate(parser:)
      errors = []
      csv_field_name = parser.work_type_field_name.to_s

      parser.parsed_csv.each_with_index do |row, idx|
        # +1 for header row
        # +1 for zero-based counting
        line_number = idx + 2
        value = row[csv_field_name]
        value = value.first if value.is_a?(Array)

        next if value.blank?

        errors << invalid_work_type_error(type: value, line_number: line_number) unless self.class.valid?(value)
      end

      errors
    end

    private

    def invalid_work_type_error(type:, line_number:)
      Error.new(self.class, "Invalid work_type", "'#{type}' is not a valid work_type", line_number)
    end
  end
end
