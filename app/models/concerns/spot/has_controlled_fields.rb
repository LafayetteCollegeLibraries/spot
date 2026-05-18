# frozen_string_literal: true
module Spot
  # Opt-in wrapping of controlled vocabulary field values in an ActiveTriples::Resource object
  module HasControlledFields
    extend ActiveSupport::Concern

    module ClassMethods
      def has_controlled_field(field, vocabulary_class: ActiveTriples::Resource)
        controlled_fields << field unless controlled_fields.include?(field)

        define_method(field.to_sym) do
          Array.wrap(try(:[], field.to_sym)).map { |v| vocabulary_class.new(v) } || nil
        end
      end

      def controlled_fields
        @spot_controlled_fields ||= []
      end
    end
  end
end
