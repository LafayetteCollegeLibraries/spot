# frozen_string_literal: true
module Hyrax
  class PublicationPresenter < Hyrax::WorkShowPresenter
    include ::Spot::PresentsAttributes

    # is this excessive?
    delegate :abstract, :academic_department, :bibliographic_citation,
             :contributor, :creator, :date_issued, :date_available,
             :division, :editor, :keyword, :language, :language_label,
             :organization, :publisher, :resource_type, :source, :subject,
             :subtitle, :title_alternative,
             to: :solr_document

    # Metadata formats we're able to export as.
    #
    # @return [Array<Symbol>]
    def export_formats
      %i[csv ttl nt jsonld]
    end

    # Overrides {Hyrax::WorkShowPresenter#page_title} by only using
    # the work's title + our product name.
    #
    # @return [String]
    def page_title
      "#{title.first} || #{I18n.t('hyrax.product_name')}"
    end

    # For now, overriding the ability to feature individual works
    # on the homepage. This should prevent the 'Feature'/'Unfeature'
    # button from rendering on the work edit page.
    #
    # @return [false]
    def work_featurable?
      false
    end

    # Is the document's visibility public?
    #
    # @return [true, false]
    def public?
      solr_document.visibility == ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    # Our document's identifiers mapped to Spot::Identifier objects
    #
    # @return [Array<Spot::Identifier>]
    def identifier
      @identifier ||= solr_document.identifier.map { |str| Spot::Identifier.from_string(str) }
    end

    # @return [Array<Spot::Identifier>]
    def local_identifier
      @local_identifier ||= identifier.select(&:local?)
    end

    # location values + labels zipped into tuples.
    #
    # @example
    #   presenter.location
    #   => [['http://sws.geonames.org/5188140/', 'Easton, PA']]
    #
    # @return [Array<Array<String>>]
    def location
      solr_document.location.zip(solr_document.location_label).reject(&:empty?)
    end

    # @return [Array<Spot::Identifier>]
    def standard_identifier
      @standard_identifier ||= identifier.select(&:standard?)
    end

    # @return [Array<Array<String>>]
    def rights_statement_merged
      solr_document.rights_statement.zip(solr_document.rights_statement_label)
    end
  end
end
