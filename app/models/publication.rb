# frozen_string_literal: true
class Publication < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # The `controlled_properties` attribute is used by the Hyrax::DeepIndexingService,
  # which is used to fetch RDF labels for indexing. This is used out-of-the-box
  # for :place (which, I believe, uses GeoNames), but could be used for,
  # say, LCSH headings in other models, if not this one. This is implemented in
  # Hyrax::BasicMetadata, but since we're implementing our basic metadata fields
  # outside of that mixin, we'll need to define this manually.
  #
  # (You'll probably also need to switch on `accepts_nested_attributes` below)

  class_attribute :controlled_properties
  self.controlled_properties = [:location]

  self.indexer = PublicationIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  validates :title, presence: { message: 'Your work must include a Title.' }
  validates :resource_type, presence: { message: 'Your work must include a Resource Type.' }
  validates :rights_statement, presence: { message: 'Your work must include a Rights Statement.' }

  validates_with ::Spot::DateIssuedValidator
  validates_with ::Spot::RequiredLocalAuthorityValidator,
                 field: :resource_type, authority: 'resource_types'
  validates_with ::Spot::RequiredLocalAuthorityValidator,
                 field: :rights_statement, authority: 'rights_statements'

  before_save :ensure_noid_in_identifier

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

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.as :stored_searchable, :facetable
  end

  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end

  property :physical_medium, predicate: ::RDF::Vocab::DC.PhysicalMedium do |index|
    index.as :stored_searchable, :facetable
  end

  # see {IndexesLanguageAndLabel} mixin for indexing
  property :language, predicate: ::RDF::Vocab::DC11.language

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC11.description do |index|
    index.as :stored_searchable
  end

  property :note, predicate: ::RDF::Vocab::SKOS.note do |index|
    index.as :stored_searchable
  end

  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :symbol
  end

  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation do |index|
    index.as :stored_searchable
  end

  property :date_issued, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :symbol
  end

  property :date_available, predicate: ::RDF::Vocab::DC.available do |index|
    index.as :symbol
  end

  property :creator, predicate: ::RDF::Vocab::DC11.creator do |index|
    index.as :stored_searchable, :facetable
  end

  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    index.as :stored_searchable, :facetable
  end

  property :editor, predicate: ::RDF::Vocab::BIBO.editor do |index|
    index.as :stored_searchable, :facetable
  end

  property :academic_department, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#AcademicDepartment') do |index|
    index.as :stored_searchable, :facetable
  end

  property :division, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Division') do |index|
    index.as :stored_searchable, :facetable
  end

  property :organization, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Organization') do |index|
    index.as :stored_searchable, :facetable
  end

  property :related_resource, predicate: ::RDF::RDFS.seeAlso do |index|
    index.as :stored_searchable, :facetable
  end

  property :subject, predicate: ::RDF::Vocab::DC11.subject do |index|
    index.as :stored_searchable, :facetable
  end

  property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords do |index|
    index.as :stored_searchable, :facetable
  end

  property :location, predicate: ::RDF::Vocab::DC.spatial,
                      class_name: Spot::ControlledVocabularies::Location do |index|
    index.as :symbol
  end

  property :license, predicate: ::RDF::Vocab::DC.license

  # rights_statements are stored as URIs
  property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder

  # accepts_nested_attributes_for needs to be defined at the end of the model.
  # see note from Hyrax::BasicMetadata mixin:
  #
  #   This must be mixed after all other properties are defined because no other
  #   properties will be defined once accepts_nested_attributes_for is called

  id_blank = proc { |attributes| attributes[:id].blank? }
  accepts_nested_attributes_for :location, reject_if: id_blank, allow_destroy: true

  private

    # @return [void]
    def ensure_noid_in_identifier
      return if id.nil?

      noid_id = "noid:#{id}"
      return if identifier.include?(noid_id)

      self.identifier += [noid_id]
    end
end
