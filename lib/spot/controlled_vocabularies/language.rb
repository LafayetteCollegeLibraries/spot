module Spot
  module ControlledVocabularies
    class Language < ActiveTriples::Resource
      configure rdf_label: ::RDF::Vocab::SKOS.prefLabel

      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label.first.to_s == rdf_subject.to_s

        best_pick = rdf_label.select { |label| label.language == preferred_language }
        return [rdf_subject.to_s] if best_pick.empty?

        [rdf_subject.to_s, { label: "#{best_pick.first}$#{rdf_subject}"}]
      end

      private

      def preferred_language
        ::Spot::RDFAuthorityParser.preferred_language
      end
    end
  end
end
