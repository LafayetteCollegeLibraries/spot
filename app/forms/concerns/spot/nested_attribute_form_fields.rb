# frozen_string_literal: true
module Spot
  # Adds support for nested attribute fields in Hyrax forms. These fields use Select2 in the UI
  # which sends data via a hash with numbered keys pointing at URI values.
  #
  # @usage
  #   class CoolResourceForm < Hyrax::ResourceForm(CoolResource)
  #     include Hyrax::Schema(:core_metadata)
  #     include Spot::NestedAttributeFormFields(:subject, :location)
  #   end
  #
  # @example incoming *_attributes data
  #   {
  #      '0' => {
  #        'id' => 'https://ldr.lafayette.edu'
  #      },
  #      '1' => {
  #        'id' => 'https://lafayette.edu'
  #      }
  #   }
  #
  # @example incoming *_attributes data with deletion intention
  #   {
  #     '0' => {
  #       'id' => 'https://ldr.lafayette.edu'
  #     },
  #     '1' => {
  #       'id' => 'https://lafayette.edu',
  #       '_destroy' => 'true'
  #      }
  #   }
  #
  def self.NestedAttributeFormFields(*fields)
    NestedAttributeFormFields.new(fields)
  end

  class NestedAttributeFormFields < Module
    include NestedAttributeHelpers

    def initialize(fields)
      @fields = fields.map(&:to_sym)
    end

    private

    def included(descendant)
      super

      @fields.each do |field|
        prepopulator = ->(_opts) { send(:"#{field}_attributes=", wrap_attribute_values(field: field)) }
        populator = ->(fragment:, **) { send(:"#{field}=", parse_attribute_fragment(fragment: fragment, field: field)) }

        descendant.property(:"#{field}_attributes",
                            virtual: true,
                            prepopulator: prepopulator,
                            populator: populator)
      end
    end
  end
end
