# frozen_string_literal: true
module Spot
  def self.AttributeFormFields(*fields)
    AttributeFormFields.new(fields)
  end

  class AttributeFormFields < Module
    module HelperMethods
      def parse_attribute_values(field:, value_key: 'id')
        adds = []
        deletes = []

        Array.wrap(send(:"#{field}_attributes")).each do |_, attrs|
          if attrs['_destroy'] == 'true'
            deletes << attrs[value_key]
          else
            adds << attrs[value_key]
          end
        end

        ((Array.wrap(send(field.to_sym)) + adds) - deletes).uniq
      end
    end

    def initialize(fields)
      @fields = fields
    end

    private

    def included(descendant)
      super

      descendant.include(HelperMethods)

      @fields.map(&:to_sym).each do |field|
        descendant.property(:"#{field}_attributes",
                            virtual: true,
                            prepopulator: ->(_opts) { send(:"#{field}") },
                            populator: ->(_opts) { send(:"#{field}=", parse_attribute_values(field: field)) })
      end
    end
  end
end
