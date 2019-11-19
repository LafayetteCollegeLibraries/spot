# frozen_string_literal: true
module Hyrax
  class PublicationPresenter < Hyrax::WorkShowPresenter
    include ::Spot::PresentsAttributes

    # is this excessive?
    delegate :abstract, :academic_department, :bibliographic_citation,
             :contributor, :creator, :date_issued, :date_available,
             :division, :editor, :keyword, :language, :language_label,
             :organization, :permalink, :publisher, :resource_type, :source,
             :subject, :subtitle, :title_alternative,
             to: :solr_document

    # @return [String]
    def export_all_text
      I18n.t("spot.work.export.download_work_and_metadata_#{multiple_members? ? 'multiple' : 'single'}")
    end

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

    # @return [true, false]
    def multiple_members?
      list_of_item_ids_to_display.count > 1
    end

    # Overrides {Hyrax::WorkShowPresenter#page_title} by only using
    # the work's title + our product name.
    #
    # @return [String]
    def page_title
      "#{title.first} // #{I18n.t('hyrax.product_name')}"
    end

    # Is the document's visibility public?
    #
    # @return [true, false]
    def public?
      solr_document.visibility == ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    # @return [Array<Array<String>>]
    def rights_statement_merged
      solr_document.rights_statement.zip(solr_document.rights_statement_label)
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

    # For now, overriding the ability to feature individual works
    # on the homepage. This should prevent the 'Feature'/'Unfeature'
    # button from rendering on the work edit page.
    #
    # @return [false]
    def work_featurable?
      false
    end
  end
end
