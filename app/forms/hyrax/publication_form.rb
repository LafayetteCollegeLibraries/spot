# frozen_string_literal: true

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

      def model_attributes(form_params)
        prefixes = form_params.delete('identifier_prefix')
        values = form_params.delete('identifier_value')

        merged = prefixes.zip(values).map do |(key, value)|
          Spot::Identifier.new(key, value).to_s
        end

        super.tap do |params|
          params[:identifier] = merged

          singular_terms.each do |term|
            params[term] = Array(params[term]) if params[term]
          end
        end
      end

      def build_permitted_params
        super.tap do |params|
          params << { identifier_prefix: [] }
          params << { identifier_value: [] }
        end
      end
    end
  end
end
