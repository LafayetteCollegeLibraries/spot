# frozen_string_literal: true
class AudioVisual < ActiveFedora::Base
  include Spot::WorkBehavior

  self.indexer = AudioVisualIndexer
  self.controlled_properties = [:location, :subject]

  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :symbol
  end

  property :date_associated, predicate: ::RDF::URI.new('https://d-nb.info/standards/elementset/gnd#associatedDate') do |index|
    index.as :symbol, :stored_searchable
  end

  property :premade_derivatives, predicate: ::RDF::URI.new('http://ldr.lafayette.edu/ns#premade_derivatives') do |index|
    index.as :symbol
  end

  property :stored_derivatives, predicate: ::RDF::URI.new('http://ldr.lafayette.edu/ns#stored_derivatives') do |index|
    index.as :symbol
  end

  property :inscription, predicate: ::RDF::URI.new('http://dbpedia.org/ontology/inscription') do |index|
    index.as :stored_searchable
  end

  property :repository_location, predicate: ::RDF::URI.new('http://purl.org/vra/placeOfRepository') do |index|
    index.as :symbol
  end

  property :research_assistance, predicate: ::RDF::URI.new('http://www.rdaregistry.info/Elements/a/#P50265') do |index|
    index.as :symbol
  end

  property :format, predicate: ::RDF::URI.new('http://purl.org/dc/terms/Format') do |index|
    index.as :stored_searchable, :facetable
  end

  property :original_item_extent, predicate: ::RDF::Vocab::DC.extent do |index|
    index.as :stored_searchable
  end

  property :barcode, predicate: ::RDF::URI.new('https://schema.org/Barcode') do |index|
    index.as :symbol
  end

  property :provenance, predicate: ::RDF::Vocab::DC.provenance do |index|
    index.as :stored_searchable, :facetable
  end

  # see {Spot::WorkBehavior.setup_nested_attributes!}
  setup_nested_attributes!
end
