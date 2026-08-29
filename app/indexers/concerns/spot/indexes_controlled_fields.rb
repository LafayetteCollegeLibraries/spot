# frozen_string_literal: true
module Spot
  # Indexing support for the Spot::HasControlledFields mixin. Since we're still using
  # ActiveTriples::Resource objects for wrapping/fetching-labels-from URIs, we'll continue
  # using conventions established in the ActiveFedora world.
  #
  # This makes two expectations that were already in place in code:
  #   1) if a model is adding a custom Controlled Vocabulary class for a field,
  #      it's expected to have been added via the Spot::HasControlledFields.has_controlled_field
  #      method, which adds a .controlled_fields class method
  #   2) a Custom Vocabulary field will respond to a #solrize instance method,
  #      which returns a tuple of the URI and a hash with a :label key
  #      pointing at the fetched label.
  #
  # @see app/models/concerns/spot/has_controlled_fields.rb
  # @see app/services/spot/deep_indexing_service.rb
  module IndexesControlledFields
    extend ActiveSupport::Concern

    included do
      class_attribute :controlled_field_value_suffix, default: '_ssim'
      class_attribute :controlled_field_label_suffix, default: '_label_ssim'
    end

    def to_solr
      super.tap do |doc|
        next doc if resource.try(:controlled_fields).blank?

        resource.controlled_fields.each do |field|
          doc.merge!(index_values_for_controlled_field(field: field))
        end
      end
    end

    def index_values_for_controlled_field(field:)
      return {} if resource.try(field).blank?

      value_key = "#{field}#{controlled_field_value_suffix}"
      label_key = "#{field}#{controlled_field_label_suffix}"

      resource.public_send(field).each_with_object({}) do |value, out|
        uri, label_hash = value.respond_to?(:solrize) ? value.solrize : [value, { label: value }]
        out[value_key] ||= []
        out[value_key] << uri

        out[label_key] ||= []
        out[label_key] << label_hash[:label] || uri
      end

      out
    end
  end
end
