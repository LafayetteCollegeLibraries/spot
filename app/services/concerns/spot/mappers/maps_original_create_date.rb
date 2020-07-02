# frozen_string_literal: true
module Spot::Mappers
  # The +:date_uploaded+ property is used to store the date of the item's original ingest.
  # This is preserved in the MetaDB technical metadata field "format.technical.DateModified".
  # In order to ensure that this is called on every item, we'll add a +date_uploaded+ method
  # and push it into the +#fields+ array (since the standard practice is to append an array
  # to the +super+ results, this will be called first).
  #
  # @example Adding a date_uploaded field to a mapper with the default metadata field "format.technical.DateModified"
  #
  #   module Spot::Mappers
  #     class LegacyCollectionMapper < BaseMapper
  #       include MapsOriginalCreateDate
  #     end
  #   end
  #
  #   Spot::Mappers::LegacyCollectionMapper.new.fields.include?(:date_uploaded)
  #   # => true
  #
  # @see https://github.com/samvera/hyrax/blob/v2.8.0/app/models/concerns/hyrax/core_metadata.rb#L20-L28
  module MapsOriginalCreateDate
    extend ActiveSupport::Concern

    included do
      class_attribute :original_create_date_field
      self.original_create_date_field = 'format.technical.DateModified'
    end

    # @return [Array<Symbol>]
    def fields
      super + [:date_uploaded]
    end

    # @return [String, nil]
    def date_uploaded
      return unless metadata.include?(original_create_date_field)

      DateTime.parse(metadata[original_create_date_field]).utc
    rescue ArgumentError
      nil
    end
  end
end
