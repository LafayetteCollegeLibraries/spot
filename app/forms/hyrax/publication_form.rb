# frozen_string_literal: true
module Hyrax
  class PublicationForm < Hyrax::Forms::WorkForm
    include ::IdentifierFormFields
    include ::LanguageTaggedFormFields
    include ::NestedFormFields

    transforms_language_tags_for :title, :title_alternative, :subtitle, :abstract, :description
    transforms_nested_fields_for :language, :academic_department, :division

    self.model_class = ::Publication
    self.required_fields = [:title, :date_issued, :resource_type, :rights_statement]
    self.terms = [
      # required_fields first
      :title,
      :date_issued,
      :resource_type,
      :rights_statement,

      # starting with rights holder since it relates to rights_statement
      :rights_holder,
      :subtitle,
      :title_alternative,
      :creator,
      :contributor,
      :editor,
      :publisher,
      :source,
      :bibliographic_citation,
      :standard_identifier,
      :local_identifier,
      :abstract,
      :description,
      :subject,
      :keyword,
      :language,
      :physical_medium,
      :location,
      :note,
      :related_resource,
      :academic_department,
      :division,
      :organization,

      # internal fields
      # These are Hyrax-specific fields that deal with embargoes,
      # parent/child relationships. These need to be present in
      # this array so that they are included in the sanitized_params
      # hash used in submission.
      :representative_id, :thumbnail_id, :rendering_ids, :files,
      :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
      :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
      :visibility, :ordered_member_ids, :in_works_ids,
      :member_of_collection_ids, :admin_set_id
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

    # An array to iterate through when building our custom portion
    # of the Publication form. The Hyrax-specific fields are excluded.
    # @return [Array<Symbol>]
    def primary_terms
      terms - [
        :representative_id, :thumbnail_id, :rendering_ids, :files,
        :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
        :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
        :visibility, :ordered_member_ids, :in_works_ids,
        :member_of_collection_ids, :admin_set_id
      ]
    end

    # @return [String, RDF::Literal]
    def abstract
      self['abstract'].first
    end

    # @return [String]
    def date_issued
      self['date_issued'].first
    end

    # @return [String, RDF::Literal]
    def title
      self['title'].first
    end

    class << self
      def build_permitted_params
        super.tap do |params|
          params << { location_attributes: [:id, :_destroy] }
          params << { subject_attributes: [:id, :_destroy] }
        end
      end

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
        %i[abstract date_issued date_available title]
      end

      # Used to transform values from the form into those that
      # get added to the object.
      #
      # @param [ActionController::Parameters, Hash] form_params
      # @return [Hash<Symbol => Array<String>>]
      def model_attributes(form_params)
        super.tap do |params|
          pluralize_singular_fields(params)
          strip_whitespace(params)
        end
      end

      private

        # We've chosen to enforce single fields at the form level,
        # rather than at the model. This appears to be more flexible
        # than updating a model property and possibly encountering
        # ActiveFedora errors when older works are out of sync.
        #
        # @param [ActiveController::Parameters, Hash<String => *>]
        # @return [void]
        def pluralize_singular_fields(params)
          singular_terms.each do |term|
            params[term] = Array(params[term]) if params[term]
          end
        end

        # @param [ActiveController::Parameters, Hash<String => *>]
        # @return [void]
        def strip_whitespace(params)
          terms.each do |key|
            if params[key].is_a? Array
              params[key] = params[key].map(&:strip).reject(&:blank?)
            elsif params[key].is_a? String
              params[key] = params[key].strip
            end
          end
        end
    end
  end
end
