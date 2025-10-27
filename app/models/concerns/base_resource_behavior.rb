# frozen_string_literal: true
module Spot
  module BaseResourceBehavior
    # Wraps stored :identifier values (strings) in our {Spot::Identifier} interface
    #
    # @see app/models/spot/identifier.rb
    # @return [Array<Spot::Identifier>]
    def identifier
      Array.wrap(self[:identifier]).map { |id| Spot::Identifier.from_string(id) }
    end

    # Wraps stored :location values (themselves wrapped in RDF::URI via Hyrax/Valkyrie) in
    # our {Spot::ControlledVocabularies::Location} interface. This conforms to the previous
    # ActiveFedora interface and gives us an entrypoint to fetch labels during indexing.
    #
    # @see app/models/spot/controlled_vocabularies/location.rb
    # @return [Array<Spot::ControlledVocabularies::Location>]
    def location
      Array.wrap(self[:location]).map { |uri| Spot::ControlledVocabularies::Location.new(uri) }
    end

    # Wraps stored :subject values (themselves wrapped in RDF::URI via Valkyrie) in
    # our {Spot::ControlledVocabularies::AssignFastSubject} interface. This conforms to the previous
    # ActiveFedora interface and gives us an entrypoint to fetch labels during indexing.
    #
    # @see app/models/spot/controlled_vocabularies/assign_fast_subject.rb
    # @return [Array<Spot::ControlledVocabularies::AssignFastSubject>]
    def subject
      Array.wrap(self[:subject]).map { |uri| Spot::ControlledVocabularies::AssignFastSubject.new(uri) }
    end
  end
end
