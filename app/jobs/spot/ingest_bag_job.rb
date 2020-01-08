# frozen_string_literal: true
#
# Parses a BagIt directory and ingests the contents. This handles the messy
# business of getting the Darlingtonia pieces in order for ingestion.
#
# @example
#   path = '/path/to/ingestable/bag'
#   Spot::IngestBagJob.perform_later(bag_path, source: 'newspaper', work_klass: 'Publication')
#
# Note: Rails can't handle symbol arguments, so be sure to convert your
#       source to a String! I _think_ this is fixed in Rails 6.
#       (see: https://github.com/rails/rails/issues/25993)
module Spot
  class IngestBagJob < ::ApplicationJob
    queue_as :ingest

    # @param [Hash] options
    # @option [String, Pathname] bag_path
    #   Path to the Bag directory
    # @option [String] source
    #   Source collection / which mapper to use
    # @option [String] work_klass
    #   Work Type to use for new object
    # @option [Array<String>] collection_ids
    #   Collection IDs to add the item to
    # @return [void]
    # @raise [ArgumentError] if +source:+ is not defined in {Spot::Mappers.available_mappers}
    # @raise [ArgumentError] if +work_class:+ not a valid Work type
    # @raise [ValidationError] if the file to parse is invalid
    #   (from Darlingtonia::Parser)
    def perform(bag_path:, source:, work_klass:, collection_ids: [])
      mapper_klass = Spot::Mappers.get(source.to_sym)
      service = BagIngestService.new(bag_path: bag_path, mapper_klass: mapper_klass,
                                     work_klass: work_klass.constantize, collection_ids: collection_ids)
      service.ingest
    end
  end
end
