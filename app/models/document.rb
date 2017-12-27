# Generated via
#  `rails generate hyrax:work Document`
class Document < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = DocumentIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Document'

  # `abstract` is currently being compounded with `description` (the label says 
  # "Abstract or Summary"). so let's break this out into its own thing + have description
  # be its own thing
  property :abstract, predicate: ::RDF::Vocab::DC.abstract, multiple: false do |index|
    index.as :stored_searchable
  end

  property :issued, predicate: ::RDF::Vocab::DC.issued, multiple: false do |index|
    index.as :stored_searchable
  end

  property :provenance, predicate: ::RDF::Vocab::DC.provenance, multiple: false do |index|
    index.as :stored_searchable
  end

  property :department, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Department'), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :division, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Division'), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  property :organization, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Organization'), multiple: true do |index|
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
