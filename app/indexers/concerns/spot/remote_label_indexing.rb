# frozen_string_literal: true
module Spot
  # Provides a helper method to the calling indexer for fetching labels from a remote source.
  module RemoteLabelIndexing
    extend ActiveSupport::Concern

    # @param [SolrDocument,Hash] document
    #   Document to append
    # @option [Symbol] field
    #   Field to call on the resource
    # @option [Class] controlled_vocabulary_class
    #   Class used to wrap the URI value and fetch a remote label. this is typically
    #   a descendant of ActiveTriples::Resource, but is expected to be initialized with
    #   a URI or String value and respond to :preferred_label.
    # @option [String, Array<String>] value_key
    #   Key (or array of keys) to store the field's original value
    # @option [String, Array<String>] label_key
    #   Key (or array of keys) to store the fetched value (fallback is original value)
    #
    # @return void
    def fetch_and_attach_remote_labels_to(document, field:, controlled_vocabulary_class: nil, value_key: nil, label_key: nil)
      value_key = Array.wrap(value_key || "#{field}_ssim")
      label_key = Array.wrap(label_key || "#{field}_label_ssim")

      values = resource.try(field) || []
      return if values.empty?

      value_label_pairs = value_label_pairs_from(values, wrapper_class: controlled_vocabulary_class)

      original_values = value_label_pairs.map(&:first)
      label_values = value_label_pairs.map(&:last)

      value_key.each { |vk| document[vk] = original_values.dup }
      label_key.each { |lk| document[lk] = label_values.dup }
    end

    private

    # Returns an array of tuples: uri and label
    def value_label_pairs_from(values, wrapper_class: nil)
      values.map do |value|
        uri = case value
              when RDF::URI
                value.to_s
              else
                value # leave as-is
              end

        wrapped_uri = wrapper_class ? wrapper_class.new(uri) : value
        label = wrapped_uri.try(:preferred_label) || uri

        [uri, label]
      end
    end
  end
end
