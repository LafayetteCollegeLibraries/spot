# frozen_string_literal: true
module Hyrax
  class PublicationPresenter < ::Spot::BasePresenter
    delegate :abstract, :academic_department, :bibliographic_citation,
             :contributor, :creator, :date_issued, :date_available,
             :division, :editor, :keyword, :language, :language_label,
             :local_identifier, :organization, :permalink, :publisher,
             :resource_type, :rights_holder, :source, :standard_identifier,
             :subtitle, :title_alternative,
             to: :solr_document

    # Metadata formats we're able to export as.
    #
    # @return [Array<Symbol>]
    def export_formats
      %i[csv ttl nt jsonld]
    end

    # @return [Array<Spot::Identifier>]
    def local_identifier
      @local_identifier ||= solr_document.local_identifier.map { |id| Spot::Identifier.from_string(id) }
    end

    def manifest_metadata_fields
      %i[
        title subtitle title_alternative creator contributor abstract description
        subject keyword date_issued standard_identifier rights_holder rights_statement
      ]
    end

    # @return [Array<Spot::Identifier>]
    def standard_identifier
      @standard_identifier ||= solr_document.standard_identifier.map { |id| Spot::Identifier.from_string(id) }
    end

    # Subject URIs and Labels in an array of tuples
    #
    # @example
    #   presenter.subject
    #   => [["http://id.worldcat.org/fast/2004076", "Little free libraries"]]
    # @return [Array<Array<String>>]
    def subject
      solr_document.subject.zip(solr_document.subject_label)
    end
  end
end
