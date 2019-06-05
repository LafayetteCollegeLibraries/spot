# frozen_string_literal: true
#
# Inflates a compressed BagIt directory and ingests the contents.
# Requires an extra parameter (+working_path:+) as a location to
# unzip the directory to (since ingestion involves enqueuing other
# jobs, we can't give it a tmpdir path that may get cleaned up
# before the job has a chance to perform)
#
# @todo clean up working directory after ingest (via callback?)
# @todo fix rubocop warning; is this _too_ configurable?
#
# rubocop:disable Metrics/ParameterLists
require 'fileutils'

module Spot
  class IngestZippedBagJob < ApplicationJob
    queue_as :ingest

    # @param [String] zip_path Path to the zip file
    # @param [String] source Source collection / which mapper to use
    # @param [String] work_class Work Type to use for new object
    # @param [String] working_path Directory to unzip the object
    # @param [Array<String>] collection_ids Array of collection ids to add this item to
    # @param [String] multi_value_character The character used in the metadata to indicate multiple values
    # @return [void]
    #
    # @raise [ArgumentError] if +working_path:+ is not a directory
    # @raise [ArgumentError] if +source:+ is not defined in {Spot::Mappers.available_mappers}
    #   (from Spot::IngestBagJob)
    # @raise [ArgumentError] if +work_class:+ not a valid Work type
    #   (from Spot::IngestBagJob)
    # @raise [ValidationError] if the file to parse is invalid
    #   (from Darlingtonia::Parser)
    #
    def perform(zip_path:,
                source:,
                work_class:,
                working_path:,
                collection_ids: [],
                multi_value_character: ';')
      raise ArgumentError, "#{working_path} is not a directory" unless File.directory?(working_path)

      destination = File.join(working_path, File.basename(zip_path, '.zip'))
      FileUtils.remove_entry(destination) if Dir.exist?(destination)

      ZipService.new(src_path: zip_path).unzip!(dest_path: destination)

      Spot::IngestBagJob.perform_now(bag_path: destination,
                                     source: source,
                                     work_class: work_class,
                                     collection_ids: collection_ids,
                                     multi_value_character: multi_value_character)
    end
  end
end
# rubocop:enable Metrics/ParameterLists
