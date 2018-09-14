# Essentially copying the work found in Hyrax::ControlledVocabularies::Location
# but does not override the `rdf_label` configuration attribute.
module Spot
  class SolrizableActiveTriplesResource < ActiveTriples::Resource
    # Return a tuple of url & label
    def solrize
      return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label.first.to_s == rdf_subject.to_s
      [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
    end
  end
end
