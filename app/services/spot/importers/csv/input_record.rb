# frozen_string_literal: true
module Spot::Importers::CSV
  # InputRecords are Darlingtonia's way of representing the transformation
  # of CSV metadata attributes into a work, using a Mapper. Previously we've
  # just used Darlingtonia's base InputRecord, but this time around there was
  # an issue with some of the automatically generated fields in the WorkTypeMapper
  # being assigned as Arrays when the Hyrax object needs them to be singular.
  #
  # This subclass removes empty values from the generated Hash so that only
  # the fields with values provided in the metadata are updated.
  class InputRecord < ::Darlingtonia::InputRecord
    # @return [Hash<Symbol => Array<*>>]
    def attributes
      super.select { |_key, value| value.present? }
    end
  end
end
