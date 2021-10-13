# frozen_string_literal: true
module Spot
  # Properties involving information about the institution (but not restricted to Lafayette College)
  #
  # @example
  #   class ScholarlyWork < ActiveFedora::Base
  #     include Spot::WorkBehavior
  #     include Spot::InstitutionalMetadata
  #   end
  module InstitutionalMetadata
    extend ActiveSupport::Concern

    included do
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
  end
end
