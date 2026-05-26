# frozen_string_literal: true
module Spot
  module Forms
    module NestedAttributes
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

        private

        # Maps a Hash of Select2-style Hashes into values for a field. Excludes values where { '_destroy' => 'true' }
        def nested_attribute_populator_for(field, value_key: 'id', destroy_key: '_destroy')
          lambda do |fragment:, **|
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

        # Converts a field into a numbered Hash for use with Select2 inputs.
        #
        # @example
        #   form.location
        #   #=> ['http://sws.geonames.org/5188140/']
        #   form.location_attributes
        #   #=> { '0' => { 'id' => 'http://sws.geonames.org/5188140/'} }
        def nested_attribute_prepopulator_for(field, value_key: 'id')
          lambda do
            attributes = Array.wrap(send(field))
                              .each_with_object({}) do |value, attrs|
                                attrs[attrs.size.to_s] = { value_key => value.to_s }
                              end

            # @todo do we need an empty value to show a new form line?
            attributes[attributes.size.to_s] = { value_key => '' }

            send(:"#{field}_attributes=", attributes)
          end
        end
      end
    end
  end
end
