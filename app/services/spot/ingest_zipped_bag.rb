# frozen_string_literal: true
require 'zip'
require 'fileutils'

module Spot
  class IngestZippedBag
    AVAILABLE_MAPPERS = {
      ldr: Spot::Mappers::LdrDspaceMapper,
    }

    def initialize(zip_path, source: nil)
      raise ArgumentError, 'Need to provide a `source:` value for a mapper' if source.nil?
      raise ArgumentError, "Unknown `source`: #{source}. Choose one of: #{sources.join(', ')}" unless sources.include?(source)

      @zip_path = zip_path
      @tmp_bag_path = ::Rails.root.join('tmp', 'ingest', File.basename(@zip_path, '.zip'))
      @mapper = AVAILABLE_MAPPERS[source]
    end

    def perform
      unzip_to_tmp_path && (importer.import if parser.validate)
    ensure
      delete_tmp_path
    end

    private

    def sources
      AVAILABLE_MAPPERS.keys
    end

    def unzip_to_tmp_path
      FileUtils.mkdir_p @tmp_bag_path

      Zip::File.open(@zip_path) do |zip_file|
        zip_file.each do |entry|
          entry.extract(File.join(@tmp_bag_path, entry.name))
        end
      end
    end

    def delete_tmp_path
      FileUtils.rm_r @tmp_bag_path
    end

    def parser
      @parser ||= Spot::Importers::Bag::Parser.new(file: @tmp_bag_path, mapper: @mapper.new)
    end

    def record_importer
      @record_importer ||= Spot::Importers::Bag::RecordImporter.new
    end

    def importer
      @importer ||= Darlingtonia::Importer.new(parser: parser,
                                              record_importer: record_importer)
    end
  end
end
