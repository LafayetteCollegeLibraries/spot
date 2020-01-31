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
    # non-solrizable values to be added
    #
    # @param [Hash] solr_doc
    # @param [String] solr_field_key
    # @param [Hash] field_info
    # @param [ActiveTriples::Resource, String] value
    def append_to_solr_doc(solr_doc, solr_field_key, field_info, value)
      return super unless object.controlled_properties.include?(solr_field_key.to_sym)

      val = value.respond_to?(:solrize) ? value.solrize : [value, { label: value }]

      # first, add the value to the default solr key
      self.class.create_and_insert_terms(solr_field_key,
                                         val.first,
                                         field_info.behaviors,
                                         solr_doc)

      return unless val.last.is_a?(Hash) && val.last.include?(:label)

      # then, add the '*_label' value to the doc
      self.class.create_and_insert_terms("#{solr_field_key}_label",
                                         label_for(val),
                                         field_info.behaviors,
                                         solr_doc)
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

      # makes sure the value can be fetched before doing a cache check
      #
      # @param [ActiveTriples::Resource] val
      def fetch_value(val)
        return unless val.respond_to? :fetch
        return if val.is_a?(Spot::ControlledVocabularies::Base) && val.label_present?

        val.fetch
      end

      # @return [Class]
      def inserter
        ActiveFedora::Indexing::Inserter
      end

      # Return a label for the solrized term.
      #
      # @param [Array] val
      #
      # @example
      #   label(["http://id.loc.gov/authorities/subjects/sh85062487", {:label=>"Hotels$http://id.loc.gov/authorities/subjects/sh85062487"}])
      #   => 'Hotels'
      def label_for(val)
        val.last[:label].split('$').first
      end
  end
end
