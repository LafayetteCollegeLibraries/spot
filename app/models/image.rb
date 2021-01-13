# frozen_string_literal: true
#
# Images are digital representations of physical objects obtained by scanning or photographing the object.
class Image < ActiveFedora::Base
  include Spot::WorkBehavior

  self.indexer = ImageIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  # if adding controlled fields (other than :location and :subject), uncomment this
  # and add the fields to the +controlled_properties+ array
  #
  # self.controlled_properties += []

  property :repository_location, predicate: ::RDF::URI.new('http://purl.org/vra/placeOfRepository') do |index|
    index.as :symbol
  end

  property :original_item_extent, predicate: ::RDF::Vocab::DC.extent do |index|
    index.as :stored_searchable
  end

  property :inscription, predicate: ::RDF::URI.new('http://dbpedia.org/ontology/inscription') do |index|
    index.as :stored_searchable
  end

  # date indexing is covered in ImageIndexer
  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :symbol
  end

  property :date_associated, predicate: ::RDF::URI.new('https://d-nb.info/standards/elementset/gnd#associatedDate') do |index|
    index.as :symbol
  end

  # about the date
  property :date_scope_note, predicate: ::RDF::Vocab::SKOS.scopeNote do |index|
    index.as :stored_searchable
  end

  # @note The URI provided is the landing page for the OCM, as a predicate doesn't exist
  property :subject_ocm, predicate: ::RDF::URI('https://hraf.yale.edu/resources/reference/outline-of-cultural-materials') do |index|
    index.as :symbol
  end

  property :requested_by, predicate: ::RDF::URI.new('http://rdf.myexperiment.org/ontologies/base/has-requester') do |index|
    index.as :symbol
  end

  property :research_assistance, predicate: ::RDF::URI.new('http://www.rdaregistry.info/Elements/a/#P50265') do |index|
    index.as :symbol
  end

  property :donor, predicate: ::RDF::Vocab::DC.provenance do |index|
    index.as :symbol
  end

  # see {Spot::WorkBehavior.setup_nested_attributes!}
  setup_nested_attributes!
end
