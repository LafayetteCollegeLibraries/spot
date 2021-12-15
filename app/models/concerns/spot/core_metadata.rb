# frozen_string_literal: true
module Spot
  # Mixin to provide common metadata fields for our work types
  #
  # @example
  #   class WorkType < ActiveFedora::Base
  #     include ::Hyrax::WorkBehavior
  #     include ::Spot::NoidIdentifier
  #     include ::Spot::CoreMetadata
  #   end
  module CoreMetadata
    extend ActiveSupport::Concern

    included do
      # A bibliographic reference for the resource.
      property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
        index.as :stored_searchable
      end

      # Free text, use authorized version if possible.
      property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
        index.as :stored_searchable, :facetable
      end

      # Free text, use authorized version if possible.
      property :creator, predicate: ::RDF::Vocab::DC11.creator do |index|
        index.as :stored_searchable, :facetable
      end

      # Free text description of the resource.
      property :description, predicate: ::RDF::Vocab::DC11.description do |index|
        index.as :stored_searchable
      end

      # Both standard and local identifiers. Values should have an prefix declaring the source.
      # @see {Spot::Identifier}
      property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
        index.as :symbol
      end

      # Free text keywords describing the resource.
      property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords do |index|
        index.as :stored_searchable, :facetable
      end

      # ISO 639-1 codes of the language(s). See {IndexesLanguageAndLabel} mixin for indexing
      property :language, predicate: ::RDF::Vocab::DC11.language

      # Geonames or Getty TGN URI, displayed as human-readable prefLabel.
      # Note: the `index.as` definition is not used but required to be present
      # in order for the DeepIndexingServivce to be called.
      #
      # @see {Spot::DeepIndexingService} for label indexing details
      property :location, predicate: ::RDF::Vocab::DC.spatial,
                          class_name: Spot::ControlledVocabularies::Location do |index|
        index.as :symbol
      end

      # Information relevant to internal maintenance of records or the original items, such as
      # administrative, digitization hardware/software, or decision documentation.
      #
      # Intended for Admin-only display
      property :note, predicate: ::RDF::Vocab::SKOS.note do |index|
        index.as :stored_searchable
      end

      # A physical material or carrier. Examples include paper, canvas, or DVD.
      property :physical_medium, predicate: ::RDF::Vocab::DC.PhysicalMedium do |index|
        index.as :stored_searchable, :facetable
      end

      # Free text, use authorized version if possible.
      property :publisher, predicate: ::RDF::Vocab::DC11.publisher do |index|
        index.as :stored_searchable, :facetable
      end

      # Include a unique identifier (such as a DOI or ISBN) and a permalink URI if one exists.
      #
      # @todo metadata application profile has this as non-faceted, remove :facetable ?
      property :related_resource, predicate: ::RDF::RDFS.seeAlso do |index|
        index.as :stored_searchable, :facetable
      end

      # The nature or genre of the resource, e.g. periodical, image.
      # Select one or more from local controlled list.
      property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
        index.as :stored_searchable, :facetable
      end

      # Free text name of the person or organization who holds rights over the resource. Use authorized version if possible.
      property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
        index.as :stored_searchable, :facetable
      end

      # URI rights statement, from a local list.
      #
      # @see {IndexesRightsStatements} for indexing details
      # @note values found at {APP_ROOT}/config/authorities/rights_statements.yml
      property :rights_statement, predicate: ::RDF::Vocab::EDM.rights

      # A related resource from which the described resource is derived. Use string
      # conforming to a formal identification system, such as a DOI, permalink URI, ISBN,
      # ISSN, or OCLC Number.
      #
      # @todo metadata application profile has this as non-faceted, remove :facetable ?
      property :source, predicate: ::RDF::Vocab::DC.source do |index|
        index.as :stored_searchable, :facetable
      end

      # Stored as OCLC FAST URI, displayed as human-readable prefLabel.
      # @see {Spot::DeepIndexingService} for label indexing details
      property :subject, predicate: ::RDF::Vocab::DC11.subject,
                         class_name: Spot::ControlledVocabularies::Base do |index|
        index.as :symbol
      end

      # Ancillary title information for the resource. A main title is required before subtitle(s) may be used.
      property :subtitle, predicate: ::RDF::URI.new('http://purl.org/spar/doco/Subtitle') do |index|
        index.as :stored_searchable
      end

      # Other forms of the title, e.g. for versions of the title in languages other than English.
      property :title_alternative, predicate: ::RDF::Vocab::DC.alternative do |index|
        index.as :stored_searchable
      end
    end
  end
end
