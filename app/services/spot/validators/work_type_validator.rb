# frozen_string_literal: true
module Spot::Validators
  # Validator ensuring that a work_type is provided to the Parser.
  # This can be assigned at the parser level on #initialize, or
  # specified in the CSV file in the field specified when initializing
  # this object (via `:csv_field` keyword).
  #
  # @example validating Parser with work_type defined
  #   parser = Spot::Importers::CSV::Parser.new(file: File.open('new_things.csv', 'r'), work_type: :publication)
  #   validator = Spot::Validators::WorkTypeValidator.new
  #   validator.validate(parser: parser) #=> returns empty array of errors
  class WorkTypeValidator < ::Darlingtonia::Validator
    # This validator is build specificially for the CSV Parser,
    # as it needs to iterate through the raw CSV data to search
    # for a 'work_type' field.
    #
    # @param [Hash] options
    # @option [Spot::Importers::CSV::Parser] parser
    # @return [Array<Error>]
    def validate(parser:)
      return [] if valid_worktype?(parser.work_type)

      errors = []
      csv_field = parser.work_type_field_name
      parser.parsed_csv.each_with_index do |row, idx|
        lineno = idx + 1
        type = row[csv_field].first
        errors << Error.new(self.class, "No '#{csv_field}' found", "", lineno) if type.blank?
        errors << Error.new(self.class, "Invalid '#{csv_field}'", "#{type} is not a valid '#{@csv_field}'") unless valid_worktype?(type)
      end
      errors
    end

    private

    def valid_worktype?(type)
      Hyrax.config.curation_concerns.include?(type.to_s.singularize.camelize.constantize)
    rescue NameError
      false
    end
  end
end
