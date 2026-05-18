# frozen_string_literal: true
module Spot
  module Forms
    # Helper methods to add virtual fields for handling form fields
    module ResourceFormHelpers
      extend ActiveSupport::Concern

      module ClassMethods
        # Adds a <field>_attributes virtual property to the form which
        # is used for Select2 typeahead dropdowns. When sync'd with the
        # resource, it converts this form into
        #
        # @example
        #   resource.subject
        #   => ['https://ldr.lafayette.edu']
        #
        #   form = Hyrax::ResourceForm.for(resource: resource)
        #   form.subject
        #   => ['https://ldr.lafayette.edu']
        #   form.subject_attributes
        #   => { '0' => 'https://ldr.lafayette.edu' }
        def nested_attributes_for(*fields)
          fields.each do |field|
            property(:"#{field}_attributes",
                     virtual: true,
                     prepopulator: nested_attribute_prepopulator_for(field),
                     populator: nested_attribute_populator_for(field))
          end
        end

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

        def language_value_populator_for(field)
          lambda do |doc:, **|
            values = Array.wrap(doc["#{field}_value"])
                          .zip(Array.wrap(doc["#{field}_language"]))
                          .map { |(value, language)| rdf_literal_from(value, language) }
                          .compact

            send(:"#{field}=", values)
          end
        end

        def language_value_prepopulator_for(field)
          lambda do
            values = Array.wrap(send(field)).map do |value|
              rdf_serializer.deserialize(value)&.value || value
            end

            send(:"#{field}_value=", values)
          end
        end

        def language_prepopulator_for(field)
          lambda do
            languages = Array.wrap(send(field)).map do |value|
              rdf_serializer.deserialize(value).language
            end

            send(:"#{field}_language=", languages)
          end
        end

        def nested_attribute_populator_for(field, value_key: 'id', destroy_key: '_destroy')
          lambda do |*, fragment:|
            adds = []
            deletes = []

            fragment.each do |_idx, attrs|
              value = attrs[value_key]
              if attrs[destroy_key] == 'true'
                deletes << value
              else
                adds << value
              end
            end

            merged_values = ((Array.wrap(send(field)).map(&:to_s) + adds) - deletes).uniq
            send(:"#{field}=", merged_values)
          end
        end

        def nested_attribute_prepopulator_for(field, value_key: 'id')
          lambda do
            attributes = Array.wrap(send(field))
                              .each_with_object({}) do |value, attrs|
                                attrs[attrs.size.to_s] = { value_key => value.to_s }
                              end

            # @todo do we need an empty value to show a new form line?
            attributes[attributes.size.to_s] = { 'id' => '' }

            send(:"#{field}_attributes=", attributes)
          end
        end

        def rdf_literal_from(value, language)
          return if value.blank?
          return RDF::Literal.new(value.to_s) if language.blank?

          RDF::Literal.new(value.to_s, language: language.to_sym)
        end

        def rdf_serializer
          @rdf_serializer ||= RdfLiteralSerializer.new
        end
      end
    end
  end
end
