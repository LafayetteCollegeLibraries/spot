# frozen_string_literal: true
module Spot
  class FileSetCSVService
    # @param [Array<FileSet>] file_sets
    # @param [Hash] options
    # @option [true, false] include_administrative
    #   whether to add privacy_fields + checksums in generated output
    # @return [String]
    def self.for(file_sets, include_administrative: false)
      new(file_sets, include_administrative: include_administrative).csv
    end

    # @param [Array<FileSet>] file_sets
    # @param [Hash] options
    # @option [true, false] include_administrative
    #   whether to add privacy_fields + checksums in generated output
    def initialize(file_sets, include_administrative: false)
      @file_sets = file_sets.respond_to?(:to_a) ? file_sets.to_a : Array.wrap(file_sets)
      @include_administrative = include_administrative
    end

    # @return [String]
    def csv
      CSV.generate do |csv|
        csv << headers
        content.each { |row| csv << row }
      end
    end

    # @return [Array<Symbol>]
    def headers
      @headers ||= %i[id label title depositor creator visibility format_label].tap do |fields|
        fields.concat(administrative_fields) if @include_administrative
      end
    end

    # @return [Array<String>]
    def content
      @content ||= @file_sets.map do |fs|
        headers.map { |field| Array.wrap(fs.try(field)).compact.join('|') }
      end
    end

    private

      # @return [Array<Symbol>]
      def administrative_fields
        %i[
          original_checksum
          etag
          read_groups
          read_users
          edit_groups
          edit_users
          discover_groups
          discover_users
        ]
      end
  end
end
