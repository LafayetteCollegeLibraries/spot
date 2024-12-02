# frozen_string_literal: true
module Spot
  # Using our own SchemaLoader for the time being to bypass an issue with the Hyrax loader
  # where 'type: uri' and 'multiple: true' fields were passing the Dry::Struct interface default
  # value of +Dry::Types::Unknown+ through, as it responds true to #present?, which was resulting
  # in new resources having default URI values of 'Unknown'
  #
  # @example
  #   # config/metadata/cool_metadata.yml
  #   attributes:
  #     subject:
  #       type: uri
  #       multiple: true
  #
  #   # app/models/cool_resource.rb
  #   class CoolResource < Hyrax::Resource
  #     include Hyrax::Schema(:cool_metadata)
  #   end
  #
  #   CoolResource.new.subject
  #   => [#<RDF::URI:0x9743c URI:Undefined>]
  #
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