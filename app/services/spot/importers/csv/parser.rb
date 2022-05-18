# frozen_string_literal: true
module Spot::Importers::CSV
  # Responsible for parsing a CSV file and producing `Darlingtonia::InputRecord`s from
  # the metadata.
  #
  # @example
  #   source_root = '/imports/new-batch'
  #   csv_file = File.open(File.join(source_root, 'new_works_metadata.csv'), 'r')
  #   parser = Spot::Importers::CSV::Parser.new(file: csv_file)
  #   record_importer = Spot::Importers::CSV::RecordImporter.new(source_directory: File.join(source_root, 'files'))
  #
  #   parser.records do |record|
  #     record_importer.import(record: record)
  #   end
  #
  class Parser < Darlingtonia::Parser
    class_attribute :work_type_field_name, :file_field_name
    self.work_type_field_name = 'work_type'
    self.file_field_name = 'file'

    DEFAULT_VALIDATORS = [
      WorkTypeValidator.new
    ].freeze

    # For use with `Darlingtonia::Parser.for(file:)`, which iterates
    # through subclasses and determines which parser will work for the file.
    #
    # @param [Hash] options
    # @option [Object] file
    # @return [true, false]
    def self.match?(file:, **_opts)
      File.extname(file) == '.csv'
    rescue TypeError
      false
    end

    attr_reader :work_type

    def initialize(file:, work_type: nil)
      super(file: file)

      raise ArgumentError, "Invalid work_type: '#{work_type}'" unless work_type.nil? || valid_work_type?(work_type)
      @work_type = work_type
    end

    def parsed_csv
      file.rewind
      CSV.new(file, headers: true, converters: ->(v) { v.split('|') }).to_enum
    end

    def records
      parsed_csv.map do |row|
        input_record = record_from_csv_row(row)
        yield input_record if block_given?
        input_record
      end
    end

    private

    # Creates an InputRecord from the CSV row data. If the row has a value for
    # the work_type_field_name ("work_type" by default), and that value is a valid
    # work_type, it will prefer that type. If the type provided in the CSV isn't valid,
    # or no type is provided, the work_type passed to the parser is used.
    # A RuntimeError will raise if no work_type is found.
    #
    # This is a little overkill, as running `parser.validate` will validate rows
    # for "work_type", but in the event that validation isn't run, this should
    # prevent things from breaking further down.
    #
    # @param [#to_h] row
    # @return [Darlingtonia::InputRecord]
    # @raises [RuntimeError]
    #   if no work_type found in the CSV or provided to the parser
    def record_from_csv_row(row)
      attributes = row.to_h
      work_type = work_type_from_attributes(attributes)
      raise 'No work_type provided to Parser' if work_type.nil?

      InputRecord.from(metadata: row.to_h, mapper: Spot::Mappers::WorkTypeMapper.for(work_type))
    end

    def valid_work_type?(type)
      return false if type.blank?

      WorkTypeValidator.valid?(type)
    end

    # @todo maybe show warning that we're ignoring an invalid work_type?
    def work_type_from_attributes(attributes)
      work_type = attributes.fetch(work_type_field_name, [])&.first
      valid_work_type?(work_type) ? work_type : @work_type
    end
  end
end
