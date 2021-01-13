# frozen_string_literal: true
class Publication < ActiveFedora::Base
  include Spot::WorkBehavior

  # if adding controlled fields (other than :location and :subject), uncomment this
  # and add the fields to the +controlled_properties+ array
  #
  # self.controlled_properties += []

  self.indexer = PublicationIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  # additional validation
  validates_with Spot::DateIssuedValidator

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
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

  property :license, predicate: ::RDF::Vocab::DC.license

  # see {Spot::WorkBehavior.setup_nested_attributes!}
  setup_nested_attributes!
end
