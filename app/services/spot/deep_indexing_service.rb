# frozen_string_literal: true
#
# This service is responsible only for indexing RDF statements
# within our objects. Other indexing is done "upstream" in the
# decendants of +Hyrax::WorkIndexer+. This expects some ground
# rules to be met in order to work:
#
#   - the object class must contain a +controlled_properties+
#     attribute. this should return an array of symbols
#   - controlled properties should be a class that responds to
#     +:solrize+ which will return an array where the first
#     item is the URI string and the second is a hash with
#     +:label+ property that is a string that conforms to a
#     string like: "<label value>$<uri>"
#
# We're following conventions from +Hyrax::DeepIndexingService+,
# in that we're overriding methods that are called within
# +ActiveFedora::RDF::IndexingService+. We've chosen to go this
# path, rather than just using +Hyrax::DeepIndexingService+
# because of a requirement of +Hyrax::BasicMetadata+ fields,
# some of which we're excluding.
module Spot
  class DeepIndexingService < ActiveFedora::RDF::IndexingService
    # Called from within {ActiveFedora::RDF::IndexingService#add_assertions}
    # to add a value to the solr doc hash. This is our failsafe to allow
    # non-solrizable values to be added.
    #
    # Adds "#{field}_ssim", "#{field}_label_tesim", and "#{field}_label_sim"
    # properties to the Solr Document.
    #
    # @param [Hash] solr_doc
    # @param [String] solr_field_key
    # @param [Hash] field_info
    # @param [ActiveTriples::Resource, String] value
    def append_to_solr_doc(solr_doc, solr_field_key, field_info, value)
      return super unless object.controlled_properties.include?(solr_field_key.to_sym)

      value_uri, value_label_hash = value.respond_to?(:solrize) ? value.solrize : [value, { label: value }]

      # uri behaviors - :symbol
      append_values(solr_doc: solr_doc, field: "#{solr_field_key}_ssim", value: value_uri)
      return unless value_label_hash.is_a?(Hash) && value_label_hash.include?(:label)

      # label behaviors - :stored_searchable, :facetable
      label = label_for(value_label_hash)
      append_values(solr_doc: solr_doc, field: "#{solr_field_key}_label_tesim", value: label)
      append_values(solr_doc: solr_doc, field: "#{solr_field_key}_label_sim", value: label)
    end

    # Fetches values (when possible) before calling up to insert
    # the value into the document.
    def add_assertions(*)
      object.controlled_properties.each do |property|
        object[property].each do |value|
          resource = value.respond_to?(:resource) ? value.resource : value
          next unless resource.is_a?(ActiveTriples::Resource)
          next if value.is_a?(ActiveFedora::Base)

          fetch_value(value)
        end
      end

      super
    end

    private

    # Replaces calls to ActiveFedora::Indexing::Inserter, which more or less does the same thing
    def append_values(solr_doc:, field:, value:)
      solr_doc[field] ||= []
      solr_doc[field] += [value]
    end

    # makes sure the value can be fetched before doing a cache check
    #
    # @param [ActiveTriples::Resource] val
    def fetch_value(val)
      val&.fetch unless val.is_a?(Spot::ControlledVocabularies::Base) && val.label_present?
    end

    # Return a label for the solrized term.
    #
    # @param [Array] val
    #
    # @example
    #   label(["http://id.loc.gov/authorities/subjects/sh85062487", {:label=>"Hotels$http://id.loc.gov/authorities/subjects/sh85062487"}])
    #   => 'Hotels'
    def label_for(val)
      val[:label].split('$').first
    end
  end
end
