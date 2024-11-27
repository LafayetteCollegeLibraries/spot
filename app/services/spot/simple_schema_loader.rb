# frozen_string_literal: true
module Spot
  class SimpleSchemaLoader < Hyrax::SimpleSchemaLoader
    class AttributeDefinition
      def type
        collection_type = if config['multiple']
                            Valkyrie::Types::Array.constructor { |v| Array(v).select { |x| x.present? && x != Dry::Types::Undefined } }
                          else
                            Identity
                          end
        collection_type.of(type_for(config['type']))
      end
    end
  end
end