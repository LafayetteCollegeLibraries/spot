# frozen_string_literal: true
class Collection < ActiveFedora::Base
  include ::Hyrax::CollectionBehavior

  class_attribute :controlled_properties
  self.controlled_properties = [:place]

  validates_with ::Spot::OnlyUrlsValidator, fields: [:related_resource]
  validates_with ::Spot::SlugValidator, fields: [:identifier]

  # title is included with +Hyrax::CoreMetadata+, which is included
  # with +Hyrax::CollectionBehavior+

  self.indexer = Spot::CollectionIndexer

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.as :stored_searchable
  end

  # see {IndexesLanguageAndLabel} mixin for indexing
  property :language, predicate: ::RDF::Vocab::DC.language

  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.as :symbol, :facetable
  end

  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :symbol
  end

  property :related_resource, predicate: ::RDF::RDFS.seeAlso do |index|
    index.as :symbol
  end

  property :location, predicate: ::RDF::Vocab::DC.spatial,
                      class_name: Spot::ControlledVocabularies::Location do |index|
    index.as :symbol
  end

  property :sponsor, predicate: ::RDF::Vocab::SCHEMA.sponsor do |index|
    index.as :stored_searchable, :facetable
  end

  id_blank = proc { |attributes| attributes[:id].blank? }
  accepts_nested_attributes_for :location, reject_if: id_blank, allow_destroy: true

  def to_param
    slug = identifier.find { |id| id.start_with? 'slug:' }
    return super unless slug.present?

    Spot::Identifier.from_string(slug).value
  end
end
