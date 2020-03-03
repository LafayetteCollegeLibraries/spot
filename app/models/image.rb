# frozen_string_literal: true
#
# Images are digital representations of physical objects
# obtained by scanning or photographing the object.
class Image < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Spot::NoidIdentifier

  class_attribute :controlled_properties
  self.controlled_properties = [:location, :subject]

  self.indexer = ImageIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  validates :title, presence: { message: 'Your work must have a title.' }

  # title is included with ::ActiveFedora::Base
  property :subtitle, predicate: ::RDF::URI.new('http://purl.org/spar/doco/Subtitle') do |index|
    index.as :stored_searchable
  end

  property :title_alternative, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end

  property :publisher, predicate: ::RDF::Vocab::DC11.publisher do |index|
    index.as :stored_searchable, :facetable
  end

  property :repository_location, predicate: ::RDF::URI.new('http://purl.org/vra/placeOfRepository') do |index|
    index.as :symbol
  end

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.as :symbol
  end

  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :symbol
  end

  property :physical_medium, predicate: ::RDF::Vocab::DC.PhysicalMedium do |index|
    index.as :stored_searchable, :facetable
  end

  property :original_item_extent, predicate: ::RDF::Vocab::DC.extent do |index|
    index.as :stored_searchable
  end

  # see {IndexesLanguageAndLabel} mixin for indexing
  property :language, predicate: ::RDF::Vocab::DC11.language

  property :description, predicate: ::RDF::Vocab::DC11.description do |index|
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

  property :creator, predicate: ::RDF::Vocab::DC11.creator do |index|
    index.as :stored_searchable, :facetable
  end

  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    index.as :stored_searchable, :facetable
  end

  property :related_resource, predicate: ::RDF::RDFS.seeAlso do |index|
    index.as :stored_searchable, :facetable
  end

  property :subject, predicate: ::RDF::Vocab::DC11.subject,
                     class_name: Spot::ControlledVocabularies::Base do |index|
    index.as :symbol
  end

  # @note The URI provided is the landing page for the OCM, as a predicate doesn't exist
  property :subject_ocm, predicate: ::RDF::URI('https://hraf.yale.edu/resources/reference/outline-of-cultural-materials') do |index|
    index.as :symbol
  end

  property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords do |index|
    index.as :stored_searchable, :facetable
  end

  property :location, predicate: ::RDF::Vocab::DC.spatial,
                      class_name: Spot::ControlledVocabularies::Location do |index|
    index.as :symbol
  end

  # rights_statements are stored as URIs
  property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder

  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :symbol
  end

  property :requested_by, predicate: ::RDF::URI.new('http://rdf.myexperiment.org/ontologies/base/has-requester') do |index|
    index.as :symbol
  end

  # @todo
  property :research_assistance, predicate: ::RDF::URI.new('http://www.rdaregistry.info/Elements/a/#P50265') do |index|
    index.as :symbol
  end

  # @todo Should this be indexed as searchable (are we using statements?
  #       ex. "Donated by Soand So") or as a symbol (are we using a name value?)
  property :donor, predicate: ::RDF::Vocab::DC.provenance

  property :note, predicate: ::RDF::Vocab::SKOS.note do |index|
    index.as :stored_searchable
  end

  # accepts_nested_attributes_for needs to be defined at the end of the model.
  # see note from Hyrax::BasicMetadata mixin:
  #
  #   This must be mixed after all other properties are defined because no other
  #   properties will be defined once accepts_nested_attributes_for is called

  id_blank = proc { |attributes| attributes[:id].blank? }

  controlled_properties.each do |property|
    accepts_nested_attributes_for property, reject_if: id_blank, allow_destroy: true
  end
end
