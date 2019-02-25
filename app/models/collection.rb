# frozen_string_literal: true
class Collection < ActiveFedora::Base
  include ::Hyrax::CollectionBehavior

  class_attribute :controlled_properties
  self.controlled_properties = [:place]

  validates_with ::Spot::OnlyUrlsValidator, fields: [:related_resource]

  # title is included with +Hyrax::CoreMetadata+, which is included
  # with +Hyrax::CollectionBehavior+

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.as :stored_searchable
  end

  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :symbol
  end

  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.as :symbol, :facetable
  end

  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :symbol
  end

  property :related_resource, predicate: ::RDF::RDFS.seeAlso do |index|
    index.as :symbol
  end

  property :place, predicate: ::RDF::Vocab::DC.spatial,
                   class_name: Spot::ControlledVocabularies::Location do |index|
    index.as :symbol
  end

  property :sponsor, predicate: ::RDF::Vocab::SCHEMA.sponsor do |index|
    index.as :stored_searchable, :facetable
  end

  id_blank = proc { |attributes| attributes[:id].blank? }
  accepts_nested_attributes_for :place, reject_if: id_blank, allow_destroy: true
end
