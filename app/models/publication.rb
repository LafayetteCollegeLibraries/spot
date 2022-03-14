# frozen_string_literal: true
class Publication < ActiveFedora::Base
  include Spot::WorkBehavior
  include Spot::InstitutionalMetadata
  include Spot::DateAvailable

  self.controlled_properties = [:location, :subject]
  self.indexer = PublicationIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  # additional validation
  validates_with Spot::DateIssuedValidator

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :date_issued, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :symbol
  end

  property :editor, predicate: ::RDF::Vocab::BIBO.editor do |index|
    index.as :stored_searchable, :facetable
  end
  property :license, predicate: ::RDF::Vocab::DC.license

  # see {Spot::WorkBehavior.setup_nested_attributes!}
  setup_nested_attributes!
end
