# frozen_string_literal: true
#
# Creating our own form field while inheriting most of the behavior
# from Hyrax. There's a little finessing that needs to be done, as
# Hyrax requires certain fields to be singular + included on the
# form for its widgets:
#
#   - +visibility+
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
      include ::LanguageTaggedFormFields
      include ::NestedFormFields
      include ::SingularFormFields
      include ::StripsWhitespace

      transforms_language_tags_for :title, :abstract, :description
      transforms_nested_fields_for :language

      # NOTE: we can't use :slug here, as it's _technically_ not a property
      # but rather a glorified identifier
      singular_form_fields :title, :abstract, :description

      self.required_fields = [:title]
      self.terms = [
        :slug,
        :title,
        :abstract,
        :description,
        :standard_identifier,
        :local_identifier,
        :language,

        # skipping subject until we get a controlled vocabulary set up for it
        # :subject,
        :location,
        :sponsor,
        :related_resource,

        # hyrax-required terms
        :visibility,
        :collection_type_gid
      ]

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

      # Since we're sussing them out with {#slug}, we need to remove
      # slugs from local identifiers.
      #
      # @return [Array<String>]
      def local_identifier
        super.reject { |id| id.start_with? 'slug:' }
      end

      # Call the .multiple? class method introduced
      #
      # @return [true, false]
      def multiple?(field)
        self.class.multiple?(field)
      end

      # Terms that we want to display form options for.
      def primary_terms
        terms - [:visibility, :collection_type_gid]
      end

      # This is used to determine what lies below the fold of the form.
      # If we don't want a fold, we should leave this empty.
      #
      # @return [Array]
      def secondary_terms
        []
      end

      # Slugs are stored as identifiers
      #
      # @return [String]
      def slug
        @slug ||= begin
          raw = self['identifier'].find { |id| id.start_with?('slug:') }
          Spot::Identifier.from_string(raw).value unless raw.nil?
        end
      end

      class << self
        # @return [Array<String, Hash>]
        def build_permitted_params
          super + [
            { location_attributes: [:id, :_destroy] },
            :slug
          ]
        end

        # Pluralizes form_params that are displayed as singular fields,
        # saving us from setting +multiple: false+ in the model.
        #
        # @param [ActionController::Parameters, Hash] form_params
        # @return [ActionController::Parameters]
        def model_attributes(form_params)
          super.tap do |params|
            if (slug = params.delete('slug'))
              params[:identifier] ||= []
              params[:identifier] << "slug:#{slug}"
            end
          end
        end

        private

        # overriding this method from +LanguageTaggedFormFields+ mixin
        # to return RDF::Literals instead of strings (Collections aren't
        # put through the actor stack + don't need to pass around the values)
        #
        # @param tuples [Array<Array<String>>]
        # @retrun [Array<RDF::Literal>]
        def map_rdf_strings(tuples)
          tuples.map do |(value, language)|
            # need to skip blank entries here, otherwise we get a blank literal
            # (""@"") which LDP doesn't like
            next if value.blank?

            language = language.present? ? language.to_sym : nil
            RDF::Literal(value, language: language)
          end.reject(&:blank?)
        end
      end
    end
  end
end
