# frozen_string_literal: true
#
# Images are digital representations of physical objects
# obtained by scanning or photographing the object.
class Image < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

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

  # @todo
  # property :repository

  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end

  property :physical_medium, predicate: ::RDF::Vocab::DC.PhysicalMedium do |index|
    index.as :stored_searchable, :facetable
  end

  # @todo
  # property :original_item_extent

  # see {IndexesLanguageAndLabel} mixin for indexing
  property :language, predicate: ::RDF::Vocab::DC11.language

  property :description, predicate: ::RDF::Vocab::DC11.description do |index|
    index.as :stored_searchable
  end

  # @todo
  # property :ethnic_group

  # @todo
  # property :inscription

  # @todo indexing
  property :date, predicate: ::RDF::Vocab::DC.date

  # @todo
  # about the date
  # property :date_scope_note

  # @todo
  # associated date
  # property :date_associated

  property :creator, predicate: ::RDF::Vocab::DC11.creator do |index|
    index.as :stored_searchable, :facetable
  end

  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    index.as :stored_searchable, :facetable
  end

  property :related_resource, predicate: ::RDF::RDFS.seeAlso do |index|
    index.as :stored_searchable, :facetable
  end

  property :subject, predicate: ::RDF::Vocab::DC11.subject do |index|
    index.as :stored_searchable, :facetable
  end

  # @todo ??
  # property :subject_ocm

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

  # @todo
  # property :requested_by

  # @todo
  # property :research_assistance

  # @todo
  # property :donor

  # @todo
  # property :note
end
