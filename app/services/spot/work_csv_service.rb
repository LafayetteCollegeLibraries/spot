# frozen_string_literal: true
#
# Taking notes from +Hyrax::FileSetCsvService+ this allows us to
# export metadata from a Work. Technically, this will work for
# anything that includes methods that map to
require 'csv'

module Spot
  class WorkCSVService
    attr_reader :work, :terms, :multi_value_separator, :include_headers

    # @param [ActiveFedora::Base,SolrDocument] work
    # @param [Array<Symbol>] :terms
    # @param [String] :multi_value_separator
    # @param [true, false] :include_headers
    def initialize(work, terms: nil, multi_value_separator: '|', include_headers: true)
      @work = work
      @terms = terms || default_terms
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
          value = work_has_property?(term) ? work.public_send(term) : ''
          values = Array.wrap(value)
          values = values.map(&:to_s)
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
    def default_terms
      %i[
        id
        title
        title_alternative
        subtitle
        creator
        contributor
        editor
        source
        resource_type
        format
        language
        abstract
        description
        identifier
        date_issued
        date_available
        academic_department
        division
        organization
        subject
        keyword
        place
        license
        rights_statement
        visibility
      ]
    end

    def work_has_property?(term)
      case work
      when ActiveFedora::Base
        work.class.properties.include?(term)
      else
        work.respond_to?(term)
      end
    end
  end
end
