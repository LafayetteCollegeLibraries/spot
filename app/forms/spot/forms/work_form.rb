# frozen_string_literal: true
module Spot
  module Forms
    # A base class for our work forms
    class WorkForm < ::Hyrax::Forms::WorkForm
      include ::IdentifierFormFields
      include ::LanguageTaggedFormFields
      include ::NestedFormFields
      include ::SingularFormFields

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

      class << self
        # Used to transform values from the form into those that
        # get added to the object.
        #
        # @param [ActionController::Parameters, Hash] form_params
        # @return [Hash<Symbol => Array<String>>]
        def model_attributes(form_params)
          super.tap do |params|
            strip_whitespace(params)
          end
        end

        private

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
end
