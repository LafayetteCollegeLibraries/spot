# frozen_string_literal: true

module Spot::Importers::Bag
  class Parser < Darlingtonia::Parser
    DEFAULT_VALIDATORS = [Spot::Validators::BagValidator.new].freeze

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

    private

    def excluded_representatives
      metadata_filenames + %w(license.txt)
    end

    def file_list
      Dir[File.join(data_dir, '*')] -
        excluded_representatives.map {|fn| File.join(data_dir, fn)}
    end

    def input_record_from(metadata)
      Darlingtonia::InputRecord.from(metadata: metadata, mapper: @mapper)
    end

    # @todo what happens when the file doesn't exist?
    def parse_csv_metadata
      {}.tap do |output|
        contents = csv_contents
        contents.shift # skip header-row
        contents.each do |row|
          output[row[0]] = row[1].to_s.split(';')
        end
      end
    end

    def path_to_csv
      metadata_filenames
        .map { |fn| File.join(data_dir, fn) }
        .find { |path| File.exist?(path) }
    end

    # breaking this out from +parse_csv_metadata+ so that we can test
    # +parse_csv_metadata+
    #
    # @return [Array<Array<String>>]
    def csv_contents
      ::CSV.read(path_to_csv)
    end

    def bag_uid
      File.basename(directory)
    end

    def data_dir
      File.join(directory, 'data')
    end

    # We need to account for an older practice that named the bag's
    # metadata file after the id of the item (ex: '237_metadata.csv')
    def metadata_filenames
      %W(
        metadata.csv
        #{bag_uid}_metadata.csv
      )
    end
  end
end
