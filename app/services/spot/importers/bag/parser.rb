# frozen_string_literal: true

module Spot::Importers::Bag
  class Parser < Darlingtonia::Parser
    DEFAULT_VALIDATORS = [Spot::Importers::Bag::Validator.new].freeze

    def initialize(file:, mapper: nil)
      super
      @mapper = mapper
    end

    # Darlingtonia::Parser is expecting :file to be an instance of File,
    # but Bags are generally directories. We're in a position where we
    # should either:
    #   - subclass the original Parser and assume that `file:` is a
    #     String/path to the Bag directory
    #   - write our Parser class to cater to our needs,
    #     using `directory:` instead of `file:`, and copying many of
    #     the methods defined in the original Parser class
    # in an effort to stay in sync with Darlingtonia, we've chosen to
    # just alias `file` with `directory` and treat the attached value as
    # a path to the Bag.
    alias_method :directory, :file

    def records
      metadata = parse_csv_metadata
      metadata[:representative_files] = file_list

      input_record = [input_record_from(metadata)]

      yield input_record if block_given?

      input_record
    end

    def excluded_representatives
      [metadata_filename, 'license.txt']
    end

    private

    def input_record_from(metadata)
      Spot::Importers::Bag::InputRecord.from(metadata: metadata, mapper: @mapper)
    end

    def parse_csv_metadata
      csv_path = File.join(data_dir, metadata_filename)
      {}.tap do |output|
        ::CSV.foreach(csv_path) do |(key, value)|
          output[key] = value.split(';')
        end
      end
    end

    def bag_uid
      File.basename(directory)
    end

    def data_dir
      File.join(directory, 'data')
    end

    def metadata_filename
      "#{bag_uid}_metadata.csv"
    end

    def file_list
      Dir[File.join(data_dir, '*')] -
        excluded_representatives.map {|fn| File.join(data_dir, fn)}
    end
  end
end
