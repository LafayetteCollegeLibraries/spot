# frozen_string_literal: true

# Parses metadata from a BagIt-style directory. We're expecing the +data/+
# directory to be laid out as follows:
#
#   .
#   |-- data
#       |-- files
#       |   |-- Barclay-TGK-vol12-2008.pdf
#       |-- license.txt
#       |-- metadata.csv
#
# - Files to be attached now live in a +files/+ subdirectory
# - Metadata lives in a +metadata.csv+ file at the root. It's expected to
#   be a "horizontal" file: one header row and one values row (rather than
#   a "vertical" file that was a series of key/value pairs). This is a more
#   typical CSV layout.
# - When present, a License file may live at the root (as "license.txt").
#   This will be added to the metadata hash under the 'license' key.

module Spot::Importers::Bag
  class Parser < Darlingtonia::Parser
    DEFAULT_VALIDATORS = [
      Spot::Validators::BagValidator.new,
      Spot::Validators::BagMetadataValidator.new
    ].freeze

    MULTI_VALUE_CHARACTER = '|'

    # +Darlingtonia::Parser+'s initializer uses the +file+ kwarg
    # for the object, but because we're dealing with directories,
    # we're redefining that attribute here and aliasing the +file+
    # attribute reader.
    #
    # Note: the +directory+ should be an absolute path.
    #
    # @param [String, Pathname] directory
    # @param [Darlingtonia::MetadataMapper] mapper
    def initialize(directory:, mapper:)
      super(file: directory)
      @mapper = mapper
    end

    alias directory file

    # I've taken to understand that +Darlingtonia+ is intended for ingest
    # workflows that involve a CSV file that contains multiple records.
    # This method, then, would create +Darlingtonia::InputRecords+ for
    # each and then yield them to be ingested. However, since we're working
    # with BagIt directories, we're only expecting one record per instance
    # (I _guess_ you could write this where a Bag contained multitudes).
    #
    # @return [Array<Darlingtonia::InputRecord>]
    # @yield [Array<Darlingtonia::InputRecord>]
    def records
      metadata = parse_csv_metadata
      metadata['representative_files'] = file_list
      metadata['license'] = license_content if license_present?

      input_record = [input_record_from(metadata)]

      yield input_record if block_given?

      input_record
    end

    private

      # Where the work we'll be doing exists
      #
      # @return [String]
      def data_directory
        File.join(directory, 'data')
      end

      # @return [Array<String>]
      def file_list
        Dir[File.join(data_directory, 'files', '**', '*')]
      end

      # @return [Darlingtonia::InputRecord]
      def input_record_from(metadata)
        Darlingtonia::InputRecord.from(metadata: metadata, mapper: @mapper)
      end

      # @return [String]
      def license_content
        File.read(license_path)
      end

      # @return [String]
      def license_path
        File.join(data_directory, 'license.txt')
      end

      # @return [true, false]
      def license_present?
        File.exist?(license_path)
      end

      # @return [String]
      def metadata_path
        File.join(data_directory, 'metadata.csv')
      end

      # Converts the CSV::Table into a Hash (and removes the
      # +'id'+ key, since we're generating ids)
      #
      # @return [Hash<String => Array<String>>]
      def parse_csv_metadata
        read_csv.first.to_h.tap do |obj|
          obj.delete('id')
        end
      end

      # Parses the +metadata.csv+ file into a +CSV::Table+ and splits values
      # on the {MULTI_VALUE_CHARACTER} constant.
      #
      # @return [CSV::Table]
      def read_csv
        CSV.read(metadata_path,
                 headers: true,
                 converters: ->(v) { v.split(MULTI_VALUE_CHARACTER) })
      end
  end
end
