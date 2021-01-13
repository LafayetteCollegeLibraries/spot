# frozen_string_literal: true
module Spot
  # Mixin to provide core work-model behavior
  module WorkBehavior
    extend ActiveSupport::Concern

    include ::Hyrax::WorkBehavior
    include NoidIdentifier
    include CoreMetadata

    included do
      # The `controlled_properties` attribute is used by the Hyrax::DeepIndexingService,
      # which is used to fetch RDF labels for indexing. This is implemented in
      # Hyrax::BasicMetadata, but since we're implementing our basic metadata fields
      # outside of that mixin, we'll need to define this manually.

      # @!attribute [rw] controlled_properties
      #   @return [Array<Symbol>]
      class_attribute :controlled_properties
      self.controlled_properties = [:location, :subject]

      # validations for CoreMetadata fields. it should be safe to include these here
      # rather than at the individual model level
      validates :title, presence: { message: 'Your work must include a Title.' }
      validates :resource_type, presence: { message: 'Your work must include a Resource Type.' }
      validates :rights_statement, presence: { message: 'Your work must include a Rights Statement.' }

      validates_with ::Spot::RequiredLocalAuthorityValidator,
                     field: :resource_type, authority: 'resource_types'
      validates_with ::Spot::RequiredLocalAuthorityValidator,
                     field: :rights_statement, authority: 'rights_statements'
    end

    module ClassMethods
      # Intended to be called at the end of your model to setup +accepts_nested_attributes_for+
      # for your controlled properties. Uses the +controlled_properties+ attribute.
      #
      # @note from Hyrax::BasicMetadata mixin:
      #   This must be mixed after all other properties are defined because no other
      #   properties will be defined once accepts_nested_attributes_for is called
      # @return true
      def setup_nested_attributes!
        id_blank = proc { |attributes| attributes[:id].blank? }

        controlled_properties.each do |property|
          accepts_nested_attributes_for property, reject_if: id_blank, allow_destroy: true
        end

        true
      end
    end
  end
end
