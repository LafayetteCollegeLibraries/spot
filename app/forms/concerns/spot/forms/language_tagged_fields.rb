# frozen_string_literal: true
module Spot
  module Forms
    module LanguageTaggedFields
      extend ActiveSupport::Concern

      module ClassMethods
        # Provides the option for a field's values to be tagged with a language.
        # In the form, a field's values are mapped to a <field>_value virtual property
        # and any RDF language metadata is mapped to a <field>_language virtual property.
        #
        # @example
        #   resource.title
        #   #=> ['the 400 Blows', RDF::Literal('Les quatres cents coups', language: :fr)]
        #   form = Hyrax::ResourceForm.for(resource: resource)
        #   form.title == resource.title
        #   #=> true
        #   form.title_value
        #   #=> ['the 400 Blows', 'Les quatres cents coups']
        #   form.title_language
        #   #=> [nil, :fr]
        def language_tagged_field(*fields)
          fields.each do |field|
            property(:"#{field}_value",
                     virtual: true,
                     prepopulator: language_value_prepopulator_for(field),
                     populator: language_value_populator_for(field))
            property(:"#{field}_language",
                     virtual: true,
                     prepopulator: language_prepopulator_for(field))
          end
        end

        private

        # A lambda function to use for converting the <field>_value and <field>_language
        # virtual fields into RDF::Literals stored in <field>
        def language_value_populator_for(field)
          lambda do |doc:, **|
            values = Array.wrap(doc["#{field}_value"])
                          .zip(Array.wrap(doc["#{field}_language"]))
                          .map do |(value, language)|
                            next if value.blank?
                            next RDF::Literal(value) if language.blank?
                            RDF::Literal(value, language: language)
                          end.compact

            send(:"#{field}=", values)
          end
        end

        # A lambda function to map RDF::Literal values to their value attribute
        # which prepopulates the <field>_value virtual field.
        def language_value_prepopulator_for(field)
          lambda do
            values = Array.wrap(model.send(field)).map do |value|
              if value.is_a?(RDF::Literal)
                rdf_serializer.deserialize(value)&.value
              else
                value.to_s
              end
            end

            send(:"#{field}_value=", values)
          end
        end

        # A lambda funciton to map RDF::Literal values to their :language attribute
        # which prepopulates the the <field>_language virtual property
        def language_prepopulator_for(field)
          lambda do
            languages = Array.wrap(model.send(field)).map do |value|
              rdf_serializer.deserialize(value)&.language
            end

            send(:"#{field}_language=", languages)
          end
        end

        def rdf_literal_or_value_from(value, language)
          return if value.blank?
          return value if language.blank?

          RDF::Literal.new(value.to_s, language: language.to_sym)
        end

        def rdf_serializer
          @rdf_serializer ||= RdfLiteralSerializer.new
        end
      end
    end
  end
end
