# frozen_string_literal: true

# An {ActiveTriples::Resource} subclass that adds a {#solrize} method
# used to generate a uri/label value for a Solr document. Use this
# class for Work properties unless you need to explicitly set
# the predicate for +rdf_label+. By default, these predicates are
# searched (in order):
#
#   - RDF::Vocab::SKOS.prefLabel
#   - RDF::Vocab::DC.title
#   - RDF::RDFS.label
#   - RDF::Vocab::SKOS.altLabel
#   - RDF::Vocab::SKOS.hiddenLabel
#
# This also finds the first 'preferred language' value of a predicate,
# rather than the first value in general (which was causing us to
# have differing language values used). We're defaulting to English.

module Spot
  class SolrizableResource < ActiveTriples::Resource
    # @return [Array<String>] either just the URI (if no label is found)
    #                         or a tuple of the uri and label/uri combined string
    def solrize
      return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label.first.to_s == rdf_subject.to_s

      best_pick = rdf_label.select { |label| label.language == preferred_language }
      return [rdf_subject.to_s] if best_pick.empty?

      [rdf_subject.to_s, { label: "#{best_pick.first}$#{rdf_subject}"}]
    end

    private

    # @return [Symbol]
    def preferred_language
      :en
    end
  end
end
