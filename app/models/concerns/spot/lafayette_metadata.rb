module Spot
  module LafayetteMetadata
    extend ActiveSupport::Concern

    included do
      property :department, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Department') do |index|
        index.as :stored_searchable, :facetable
      end

      property :division, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Division') do |index|
        index.as :stored_searchable, :facetable
      end

      property :organization, predicate: ::RDF::URI.new('http://vivoweb.org/ontology/core#Organization') do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end
end
