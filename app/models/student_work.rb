# frozen_string_literal: true
class StudentWork < ActiveFedora::Base
  include Spot::WorkBehavior
  include Spot::InstitutionalMetadata

  self.indexer = StudentWorkIndexer
  self.controlled_properties = [:subject]

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :access_note, predicate: ::RDF::Vocab::DC.accessRights do |index|
    index.as :stored_searchable
  end

  # @todo this predicate may exist in the RDF::Vocab library
  property :advisor, predicate: ::RDF::URI.new('http://id.loc.gov/vocabulary/relators/ths') do |index|
    index.as :symbol
  end

  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
    index.as :stored_searchable
  end

  property :date, predicate: ::RDF::Vocab::DC.date

  property :date_available, predicate: ::RDF::Vocab::DC.available do |index|
    index.as :symbol
  end

  setup_nested_attributes!
end
