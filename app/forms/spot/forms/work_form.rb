# frozen_string_literal: true
module Spot
  module Forms
    # A base class for our work forms
    class WorkForm < ::Hyrax::Forms::WorkForm
      include ::IdentifierFormFields
      include ::LanguageTaggedFormFields
      include ::NestedFormFields
      include ::SingularFormFields
      include ::StripsWhitespace

      # These are Hyrax-specific fields that deal with embargoes,
      # parent/child relationships. These need to be present in
      # this array so that they are included in the sanitized_params
      # hash used on submission.
      class_attribute :hyrax_form_fields
      self.hyrax_form_fields = [
        :representative_id, :thumbnail_id, :rendering_ids, :files,
        :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
        :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
        :visibility, :ordered_member_ids, :in_works_ids,
        :member_of_collection_ids, :admin_set_id
      ]

      # class method used to transform the form parameters into attributes for the work.
      # a bunch of the form concerns will sub-method this and use a +super+ call to chain
      # them together, so don't forget to include +super+!
      #
      # we're using this in the form to ensure that the values for +rights_statement+ are
      # stored as +ActiveTriples::Resource+s
      #
      # @param [ActionController::Parameters, Hash] form_params
      # @return [ActionController::Parameters]
      def self.model_attributes(form_params)
        super.tap do |params|
          params['rights_statement'] = Array.wrap(params['rights_statement']).map { |v| RDF::URI(v) }
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
      # @return [TrueClass, FalseClass]
      def multiple?(term)
        self.class.multiple?(term)
      end

      # our rights_statement URIs may be stored as +ActiveTriples::Resource+ objects
      # (rather than Strings), so we'll want to make sure that the value is displayed
      # in the <select> object.
      #
      # @return [Array<String>]
      def rights_statement
        self['rights_statement'].map { |v| v.respond_to?(:id) ? v.id : v }
      end
    end
  end
end
