# frozen_string_literal: true
module Hyrax
  class PublicationPresenter < ::Spot::BasePresenter
    humanize_date_fields :date_issued

    delegate :abstract, :academic_department, :bibliographic_citation,
             :date_available, :division, :editor, :organization,
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
