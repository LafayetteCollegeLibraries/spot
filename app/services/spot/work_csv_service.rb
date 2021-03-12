# frozen_string_literal: true
#
# Taking notes from +Hyrax::FileSetCsvService+ this allows us to
# export metadata from a Work. Technically, this will work for
# anything that includes methods that map to
require 'csv'

module Spot
  class WorkCSVService
    attr_reader :work, :terms, :multi_value_separator, :include_headers

    def self.for(work, terms: nil, multi_value_separator: '|', include_headers: true)
      new(work, terms: terms, multi_value_separator: multi_value_separator, include_headers: include_headers).csv
    end

    # @param [ActiveFedora::Base,SolrDocument] work
    # @param [Array<Symbol>] :terms
    # @param [String] :multi_value_separator
    # @param [true, false] :include_headers
    def initialize(work, terms: nil, multi_value_separator: '|', include_headers: true)
      @work = work
      @terms = terms || default_fields
      @multi_value_separator = multi_value_separator
      @include_headers = include_headers
    end

    # @return [String]
    def csv
      [].tap do |out|
        out << headers if include_headers
        out << content
      end.join
    end

    # @return [String]
    def content
      ::CSV.generate do |csv|
        csv << terms.map do |term|
          values = term == :files ? file_sets.map(&:label) : work.try(term)
          values = values.respond_to?(:to_a) ? values.to_a : [values]
          values = values.compact.map(&:to_s)
          values.join(multi_value_separator)
        end
      end
    end

    # @return [String]
    def headers
      ::CSV.generate { |csv| csv << terms }
    end

    private

      # @return [Array<Symbol>]
      def default_fields
        [:id] + (work_class_properties - fields_to_skip) + [:files]
      end

      def fields_to_skip
        %i[
          head
          tail
          access_control_id
          representative_id
          rendering_ids
          embargo_id
          lease_id
        ]
      end

      # Fetches an array of SolrDocuments for a work's file_sets
      #
      # @return [Array<SolrDocument>]
      def file_sets
        work.file_set_ids.map { |id| SolrDocument.find(id) }
      end

      # @return [Array<Symbol>]
      def work_class_properties
        base = if work.is_a?(ActiveFedora::Base)
                 work.class&.properties
               elsif work.is_a?(SolrDocument)
                 work.hydra_model&.properties
               end

        return [] if base.nil?

        base.keys.map(&:to_sym)
      end
  end
end
