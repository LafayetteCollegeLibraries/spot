# frozen_string_literal: true

# A base class to extend how we're handling the indexing of RDF
# data within our models. To use this, add a +class_name+
# parameter to an +ActiveFedora::Base+ model.
#
# @example
#   class Image < ActiveFedora::Base
#     property :subject, predicate: RDF::URI('http://wherever/subject'),
#                        class_name: ControlledVocabularies::Base
#   end
#
# This borrows heavily from code written by Michael Klein
# of Northwestern University (see: https://github.com/nulib/donut/pull/377/files)
module Spot
  module ControlledVocabularies
    class Base < ActiveTriples::Resource

      # adds GeoNames/name to the list of predicates
      #
      # @return [Array<RDF::URI>]
      def default_labels
        @default_labels ||= super + [::RDF::Vocab::GEONAMES.name]
      end

      # calls on {ActiveTriples::Resource#fetch} but adds:
      # - caching the label to prevent repeat fetches
      # - making 3 attempts at fetching
      def fetch(*args)
        tries = 3
        begin
          super(*args).tap do
            RdfLabel.first_or_create(uri: rdf_subject.to_s) do |label|
              label.value = pick_preferred_label
            end
            @preferred_label = nil
          end
        rescue StandardError => e
          Rails.logger.warn("Fetching <#{rdf_subject}> failed: #{e.message}. Retries remaining #{tries -= 1}")
          return self if tries.zero?
          sleep(5)
          retry
        end
      end

      # Does this value have a label or is it just an URI?
      #
      # @return [TrueClass,FalseClass]
      def label_present?
        preferred_label != rdf_subject.to_s
      end

      # Chooses the preferred label by checking the cache first
      # and delegating to {#pick_preferred_label} otherwise.
      #
      # @return [String]
      def preferred_label
        @preferred_label ||= RdfLabel.find_by(uri: rdf_subject.to_s)&.value
        @preferred_label ||= pick_preferred_label
      end

      # @return [Array<String>] either just the URI (if no label is found)
      #                         or a tuple of the uri and label/uri combined string
      def solrize
        return [rdf_subject.to_s] unless label_present?
        [rdf_subject.to_s, { label: "#{preferred_label}$#{rdf_subject}"}]
      end

      private

      # @return [String]
      def pick_preferred_label
        return rdf_label.first if rdf_label.first.is_a? String

        eng_label = rdf_label.select { |label| label.language == :en }&.first
        eng_label.present? ? eng_label.to_s : rdf_label.first.to_s
      end
    end
  end
end
