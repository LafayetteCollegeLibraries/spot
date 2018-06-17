# frozen_string_literal: true

module Spot::Importers
  module Bag
    class Mapper < ::Darlingtonia::HashMapper
      PREDICATES_MAP = {
        title: ::RDF::Vocab::DC.title.to_s,
        publisher: ::RDF::Vocab::DC11.publisher.to_s,
        source: ::RDF::Vocab::DC.source.to_s,
        resource_type: ::RDF::Vocab::DC.type.to_s,
        language: ::RDF::Vocab::DC11.language.to_s,
        abstract: ::RDF::Vocab::DC.abstract.to_s,
        description: ::RDF::Vocab::DC11.description.to_s,
        identifier: ::RDF::Vocab::DC.identifier.to_s,
        issued: ::RDF::Vocab::DC.issued.to_s,
        available: ::RDF::Vocab::DC.available.to_s,
        # date_created: ::RDF::Vocab::DC.created.to_s,
        date_created: ::RDF::Vocab::DC.date.to_s,
        creator: ::RDF::Vocab::DC11.creator.to_s,
        contributor: ::RDF::Vocab::DC11.contributor.to_s,
        rights_statement: ::RDF::Vocab::DC.rights.to_s,
        academic_department: ::RDF::URI.new('http://vivoweb.org/ontology/core#AcademicDepartment').to_s,
        division: ::RDF::URI.new('http://vivoweb.org/ontology/core#Division').to_s,
        organization: ::RDF::URI.new('http://vivoweb.org/ontology/core#Organization').to_s,

        subject: ::RDF::Vocab::DC11.subject,
        # extent: ::RDF::Vocab::DC.extent,

        # :spatial => ::RDF::Vocab::DC.spatial,
        # :temporal => ::RDF::Vocab::DC.temporal,
        # :date => ::RDF::Vocab::DC11.date,
        # :copyright => ::RDF::Vocab::DC.dateCopyrighted,
        # :submitted => ::RDF::Vocab::DC.dateSubmitted,
        # :provenance => ::RDF::Vocab::DC.provenance,
        # :format => ::RDF::Vocab::DC.format,
        # :medium => ::RDF::Vocab::DC.medium,

        # :hasVersion => ::RDF::Vocab::DC.hasVersion,
        # :isreplacedby => ::RDF::Vocab::DC.isReplacedBy,
        # :replaces => ::RDF::Vocab::DC.replaces,
        # :requires => ::RDF::Vocab::DC.requires,
        # :isversionof => ::RDF::Vocab::DC.isVersionOf,
        # :ispartof => ::RDF::Vocab::DC.isPartOf,
        # :isformatof => ::RDF::Vocab::DC.isFormatOf,
        # :haspart => ::RDF::Vocab::DC.hasPart,
        # :relation => ::RDF::Vocab::DC11.relation,

        # :rightsholder => ::RDF::Vocab::DC.rightsHolder,
        # :embargo => 'http://projecthydra.org/ns/auth/acl#hasEmbargo'
      }.freeze

      # Mapper#fields is what generates the hash of attributes that are passed
      # to the model's `.new` method. for the most part, the PREDICATES_MAP
      # hash will work fine, but there are some cases where we'll provide our
      # own methods to this class (see: Mapper#visibility) that will do their
      # own thing and return a value instead.
      def fields
        PREDICATES_MAP.keys + [:visibility]
      end

      def map_field(name)
        metadata[PREDICATES_MAP[name.to_sym]]
      end

      def representative_file
        @metadata[:representative_files]
      end

      # TODO: determine the visibility based on a field within the metadata
      def visibility
        ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end
    end
  end
end
