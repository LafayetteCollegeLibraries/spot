# frozen_string_literal: true
module Spot
  class WorkTypeInventoryService
    PROPERTIES_TO_IGNORE = %w[head tail].freeze

    def self.for(work_type:, io:)
      new(work_type: work_type).write_inventory(io: io)
    end

    attr_reader :work_type, :model

    def initialize(work_type:)
      @work_type = work_type.to_s.downcase
      @model = @work_type.titleize.constantize
    end

    def write_inventory(io:)
      csv = CSV.new(io)
      batch_size = 100
      offset = 0
      total_hits = nil

      # start with headers
      csv << properties

      loop do
        res = solr_documents(rows: batch_size, start: offset)
        total_hits = res[:total]

        res[:documents].each { |doc| csv << metadata_for(doc) }

        offset += batch_size
        break if offset > total_hits
      end

      csv.close
    end

    private

      def metadata_for(solr_document)
        properties_for_model.map do |property|
          Array.wrap(solr_document.send(property.to_sym)).join('|')
        end
      end

      def properties
        @properties ||= (['id'] + model.constantize.properties.keys - PROPERTIES_TO_IGNORE)
      end

      def solr_documents(rows:, start:)
        res = ActiveFedora::SolrService.get("has_model_ssim:#{model}", rows: rows, start: start)

        {
          total: res.dig('response', 'numFound') || 0,
          documents: (res.dig('response', 'docs') || []).map { |raw| SolrDocument.new(raw) }
        }
      end
  end
end
