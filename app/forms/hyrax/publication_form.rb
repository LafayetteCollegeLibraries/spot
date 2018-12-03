# frozen_string_literal: true

# @todo We should probably move the local-controlled-vocabulary
#       transformation stuff into a mixin that adds a class_attribute
#       where we can define those fields once + it takes care of
#       the +build_permitted_params+ and +transform_nested_fields+ work
module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    self.model_class = ::Publication
    self.required_fields = [:title]
    self.terms = [
      # titles
      :title,
      :subtitle,
      :title_alternative,

      # provenance
      :creator,
      :contributor,
      :editor,
      :publisher,
      :source,
      :academic_department,
      :division,
      :organization,

      # description
      :abstract,
      :description,
      :date_issued,
      :date_available,
      :resource_type,
      :physical_medium,
      :language,
      :subject,
      :keyword,
      :based_near,
      :bibliographic_citation,
      :identifier,
      :related_resource,
      :rights_statement,

      # internal fields
      # These are Hyrax-specific fields that deal with embargoes,
      # parent/child relationships. These need to be present in
      # this array so that they are included in the sanitized_params
      # hash used in submission.
      :representative_id, :thumbnail_id, :rendering_ids, :files,
      :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
      :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
      :visibility, :ordered_member_ids, :in_works_ids,
      :member_of_collection_ids, :admin_set_id,
    ]

    # samvera/hydra-editor uses both the class method (new form) and
    # instance method (edit form) versions of this method, so we need
    # to provide both (otherwise we're head-first down a rabbit hole
    # to figure out why it's not working). This is just a wrapper around
    # the class method. I'm not 100% certain that the +super+ call
    # of the class method will mess up the instance method, but I
    # _think_ they both end up at the same FieldMetadataService
    # anyway, which is alright.
    #
    # @param [String,Symbol] term
    # @return [TrueClass, FalseClass]
    def multiple?(term)
      self.class.multiple?(term)
    end

    # an array to iterate through when building our custom portion
    # of the Publication form. Excluded are the
    # @return [Array<Symbol>]
    def primary_terms
      terms - [
        :representative_id, :thumbnail_id, :rendering_ids, :files,
        :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
        :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
        :visibility, :ordered_member_ids, :in_works_ids,
        :member_of_collection_ids, :admin_set_id,
      ]
    end

    # @return [String]
    def abstract
      self['abstract'].first
    end

    # @return [String]
    def date_issued
      self['date_issued'].first
    end

    # @return [String]
    def date_available
      self['date_available'].first
    end

    class << self

      # samvera/hydra-editor uses both the class method (new form) and
      # instance method (edit form) versions of this method, so we need
      # to provide both (otherwise we're head-first down a rabbit hole
      # to figure out why it's not working). This is just a wrapper around
      # the class method. I'm not 100% certain that the +super+ call
      # of the class method will mess up the instance method, but I
      # _think_ they both end up at the same FieldMetadataService
      # anyway, which is alright.
      #
      # @param [String,Symbol] term
      # @return [TrueClass,FalseClass]
      def multiple?(term)
        return false if singular_terms.include?(term.to_sym)
        super
      end

      # @return [Array<Symbol>]
      def singular_terms
        %i(
          resource_type
          abstract
          date_issued
          date_available
        )
      end

      # adds our custom fields to the fields allowed to be
      # passed on to our objects
      def build_permitted_params
        super.tap do |params|
          params << {
            identifier_prefix: [],
            identifier_value: [],

            # language-tagged fields
            title_value: [],
            title_language: [],
          }

          # locally controlled attibutes
          params << {
            language_attributes: [:id, :_destroy],
            academic_department_attributes: [:id, :_destroy],
            division_attributes: [:id, :_destroy]
          }
        end
      end

      # responsible for transforming the (permitted) form
      # fields into attributes to apply to the model. if
      # a form field needs to be transformed, this is probably
      # the place to do it.
      #
      # @param [ActionController::Parameters, Hash] form_params
      # @return [Hash<Symbol => Array<String>>]
      def model_attributes(form_params)
        super.tap do |params|
          transform_identifiers!(params)
          transform_nested_fields!(params,
                                  :language,
                                  :academic_department,
                                  :division)
          transform_language_tagged_fields!(params,
                                            :title)

          singular_terms.each do |term|
            params[term] = Array(params[term]) if params[term]
          end
        end
      end

      private

      # transforms arrays of identifier prefixes
      # and values into a single array of identifier
      # strings and appends it to +form_params['identifier']+
      #
      # @param [ActiveController::Parameters, Hash] params
      # @return [void]
      def transform_identifiers!(params)
        prefixes = params.delete('identifier_prefix')
        values = params.delete('identifier_value')

        return unless prefixes && values

        mapped = prefixes.zip(values).map do |(key, value)|
          Spot::Identifier.new(key, value).to_s
        end.reject(&:blank?)

        params['identifier'] = mapped if mapped
      end


      # transforms arrays of field values + languages into RDF::Literals
      # tagged with said language
      #
      # @param [ActiveController::Parameters, Hash<String => Array<String>>] params
      # @param [String,Symbol] fields
      # @return [void]
      def transform_language_tagged_fields!(params, *fields)
        fields.flatten.each do |field|
          value_key = "#{field}_value"
          lang_key = "#{field}_language"

          next unless params.include?(value_key) && params.include?(lang_key)

          values = params.delete(value_key)
          langs = params.delete(lang_key)

          mapped = values.zip(langs).map do |(value, lang)|
            # need to skip blank entries here, otherwise we get a blank literal
            # (""@"") which LDP doesn't like
            next unless value.present?

            # retain the value if no language tag is passed
            lang.present? ? RDF::Literal(value, language: lang.to_sym) : value
          end.reject(&:blank?)

          params[field] = mapped if mapped
        end
      end

      # there could probably be a clearer name for this.
      # local controlled vocabulary fields are returned
      # to the form looking like
      # +WorkModel.accepts_nested_attributes_for+ properties.
      # however, they're decidedly _not_ ActiveFedora nested
      # attributes and they need to be transformed back.
      # note that this step isn't necessary if we're
      # just using the jquery-ui autocomplete field type.
      #
      # @example
      #   def model_attributes(form_params)
      #     super.tap do |params|
      #       transform_nested_fields!(params, :language, :division)
      #     end
      #   end
      #
      #   # so that
      #   #   {'language_attributes' => {'0' => { 'id' => 'en' }}}
      #   # becomes
      #   #   {'language' => ['en']}
      #
      # @param [ActionController::Parameters, Hash] params
      # @param [Array<String,Symbol>] fields
      # @return [void]
      def transform_nested_fields!(params, *fields)
        fields.flatten.each do |field|
          attr_field_key = "#{field}_attributes"
          next unless params.include?(attr_field_key)

          values = transform_nested_attributes(params, attr_field_key)

          params[field] = values || []
        end
      end

      # flattens a nested_attribute hash into an array of
      # ids. if the +_destroy+ key is present, the field
      # is skipped, removing it from the record.
      #
      # @param [ActionController::Parameters,Hash] params
      # @param [Symbol,String] field
      # @return [Array<String>]
      def transform_nested_attributes(params, field)
        return if params[field].blank?

        [].tap do |out|
          params.delete(field.to_s).each do |_index, param|
            next unless param['_destroy'].blank?
            out << param['id'] if param['id']
          end
        end
      end
    end
  end
end
