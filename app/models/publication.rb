class Publication < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = PublicationIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :publisher, predicate: ::RDF::Vocab::DC11.publisher do |index|
    index.as :stored_searchable, :facetable
  end

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.as :stored_searchable
  end

  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end

  # TODO: we'll want to index the full-string version of the language,
  # instead of (or in addition to) its RFC-5646 value
  property :language, predicate: ::RDF::Vocab::DC11.language

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC11.description do |index|
    index.as :stored_searchable
  end

  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :stored_searchable
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
    index.as :stored_searchable
  end

  property :contributor, predicate: ::RDF::Vocab::DC11.contributor do |index|
    index.as :stored_searchable
  end

  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable
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
end
