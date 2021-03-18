# frozen_string_literal: true
require 'bagit'
require 'csv'

module Spot
  class InvalidBagError < ArgumentError; end

  class BagExtractionService
    delegate :valid?, to: :@bag

    # @param [String,Pathname] bag_path Path to a BagIt directory
    def initialize(bag_path)
      @bag = BagIt::Bag.new(bag_path)
    end

    def file_set_attributes
      @file_set_attributes ||= extract_file_set_attributes
    end

    def work_model
      work_attributes['has_model'].constantize
    end

    def work_attributes
      @work_attributes ||= cleanup_work_attributes(raw_attributes['metadata'])
    end

    def to_hyrax_attributes; end

    private

      def parse_csv(relative_path)
        path = File.realpath(File.join(@bag.data_dir, relative_path))
        CSV.parse(File.read(path), headers: true, converters: [->(v) { v.split('|') }]).first.to_h
      end

      def raw_attributes
        @raw_attributes ||= begin
          metadata = parse_csv('metadata.csv')
          files_metadata = raw_file_attributes(metadata['files'])

          { 'metadata' => metadata, 'files' => files_metadata }
        end
      end

      def raw_file_attributes(filenames)
        filenames.each_with_object({}) do |filename, attributes|
          csv_name = "metadata-#{filename.gsub(/\W+/, '-')}.csv"
          attributes[filename] = parse_csv(csv_name) if File.exist?(File.join(@bag.data_dir, csv_name))
        end
      end

      def cleanup_work_attributes(attrs)
        attrs['identifier'] = attrs['identifier'].map { |id| Spot::Identifier.from_string(id) }
        attrs['has_model'] = attrs['has_model'].first

        attrs
      end

      def cleanup_file_set_attributes(attrs)
        attrs
      end
  end
end
