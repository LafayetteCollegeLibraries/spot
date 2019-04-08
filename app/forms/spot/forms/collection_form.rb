# frozen_string_literal: true
#
# Creating our own form field while inheriting most of the behavior
# from Hyrax. There's a little finessing that needs to be done, as
# Hyrax requires certain fields to be singular + included on the
# form for its widgets:
#
#   - +visibility+
#   - +representative_id+
#   - +collection_type_gid+
#   - +thumbnail_id+
#
# As we've seen with https://github.com/LafayetteCollegeLibraries/spot/issues/203,
# having these be re-hydrated as arrays in {.model_attributes} results
# in their falling into the cracks + not being updated.
#
# @todo centralize the Hyrax attributes as a class_attribute? so that
#       we don't have to spell out each field every time they need
#       to be accounted for.
module Spot
  module Forms
    class CollectionForm < Hyrax::Forms::CollectionForm
      include ::IdentifierFormFields
      include ::NestedFormFields

      transforms_nested_fields_for :language

      class_attribute :singular_fields
      self.singular_fields = [
        :title,
        :abstract,
        :description,

        # the hyrax form-fields are also singular!
        :visibility,
        :representative_id,
        :collection_type_gid,
        :thumbnail_id
      ]

      self.required_fields = [:title]
      self.terms = [
        :title,
        :abstract,
        :description,
        :identifier,
        :language,

        # skipping subject until we get a controlled vocabulary set up for it
        # :subject,
        :place,
        :sponsor,
        :related_resource,

        # hyrax-required terms
        :visibility,
        :representative_id,
        :collection_type_gid,
        :thumbnail_id
      ]

      class << self
        # @return [Array<String, Hash>]
        def build_permitted_params
          super + [
            :thumbnail_id,
            { place_attributes: [:id, :_destroy] }
          ]
        end

        # Pluralizes form_params that are displayed as singular fields,
        # saving us from setting +multiple: false+ in the model.
        #
        # @param [ActionController::Parameters, Hash] form_params
        # @return [ActionController::Parameters]
        def model_attributes(form_params)
          super.tap do |params|
            fields = singular_fields - [
              :visibility,
              :representative_id,
              :collection_type_gid,
              :thumbnail_id
            ]

            fields.each do |field|
              field = field.to_s
              params[field] = Array(params[field]) if params[field]
            end
          end
        end

        # Should we display an "add another value" option
        # in the form?
        #
        # @param field [String, Symbol]
        # @return [true, false]
        def multiple?(field)
          !singular_fields.include? field.to_sym
        end
      end

      # Limiting to one abstract via the form
      #
      # @return [String]
      def abstract
        self['abstract'].first
      end

      # Limiting to one description via the form
      #
      # @return [String]
      def description
        self['description'].first
      end

      # Copied from +Hyrax::Forms::WorkForm+. We need to initialize
      # controlled vocabulary fields differently from the rest. Otherwise
      # we'll get the field's hint text but no input field.
      #
      # @param key [#to_s] field to try
      # @return [void]
      def initialize_field(key)
        class_name = model_class.properties[key.to_s].try(:class_name)
        return super unless class_name

        self[key] += [class_name.new]
      end

      # Delegates to the class {.multiple?} method
      #
      # @return [true, false]
      def multiple?(field)
        self.class.multiple?(field)
      end

      # Terms that we want to display form options for.
      def primary_terms
        terms - [
          :visibility,
          :representative_id,
          :collection_type_gid,
          :thumbnail_id
        ]
      end

      # This is used to determine what lies below the fold of the form.
      # If we don't want a fold, we should leave this empty.
      #
      # @return [Array]
      def secondary_terms
        []
      end

      # Limiting to one title via the form
      #
      # @return [String]
      def title
        self['title'].first
      end
    end
  end
end
