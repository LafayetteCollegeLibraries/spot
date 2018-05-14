class Publication < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # The `controlled_properties` attribute is used by the Hyrax::DeepIndexingService,
  # which is used to fetch RDF labels for indexing. This is used out-of-the-box
  # for :based_near (which, I believe, uses GeoNames), but could be used for,
  # say, LCSH headings in other models, if not this one. This is implemented in
  # Hyrax::BasicMetadata, but since we're implementing our basic metadata fields
  # outside of that mixin, we'll need to define this manually.
  #
  # (You'll probably also need to switch on `accepts_nested_attributes` below)

  # class_attribute :controlled_properties
  # self.controlled_properties = []

  self.indexer = PublicationIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  validates :title, presence: { message: 'Your work must have a title.' }

  property :publisher, predicate: ::RDF::Vocab::DC11.publisher do |index|
    # publisher_ssim
    index.as :symbol
  end

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    # source_ssim
    index.as :symbol
  end

  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    # resource_type_ssim
    index.as :symbol
  end

  # TODO: we'll want to index the full-string version of the language,
  # instead of (or in addition to) its RFC-5646 value
  property :language, predicate: ::RDF::Vocab::DC11.language

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    # abstract_tesim
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC11.description do |index|
    # description_tesim
    index.as :stored_searchable
  end

  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    # identifier_ssim
    index.as :symbol
  end

  property :issued, predicate: ::RDF::Vocab::DC.issued do |index|
    # index.type :date
    index.as :stored_searchable
  end

  property :available, predicate: ::RDF::Vocab::DC.available do |index|
    # index.type :datetime
    index.as :stored_searchable
  end

  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    # index.type :datetime
    index.as :stored_searchable
  end

  property :creator, predicate: ::RDF::Vocab::DC11.creator do |index|
    # creator_ssim
    index.as :symbol
  end

  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    # contributor_ssim
    index.as :symbol
  end

  # no need to store these in the index
  property :rights_statement, predicate: ::RDF::Vocab::DC.rights

  property :academic_department, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#AcademicDepartment') do |index|
    # academic_department_ssim
    index.as :symbol
  end

  property :division, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Division') do |index|
    # division_ssim
    index.as :symbol
  end

  property :organization, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Organization') do |index|
    # organization_ssim
    index.as :symbol
  end

  # accepts_nested_attributes_for needs to be defined at the end of the model.
  # see note from Hyrax::BasicMetadata mixin:
  #
  #   This must be mixed after all other properties are defined because no other
  #   properties will be defined once accepts_nested_attributes_for is called

  # id_blank = proc { |attributes| attributes[:id].blank? }
  # accepts_nested_attributes_for :based_near, reject_if: id_blank, allow_destroy: true
end
