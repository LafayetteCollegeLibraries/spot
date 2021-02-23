# frozen_string_literal: true
module Spot
  # A starting point for our WorkShow presenters, which adds our
  # metadata presentation method overrides as well as some
  # across-the-board rules (disabling {#work_featurable?}, an updated
  # {#page_title}, etc). When subclassing, you'll just want to
  # be sure you delegate the displayable properties to the
  # Solr document.
  #
  # @example
  #   class Hyrax::WorkPresenter < ::Spot::BasePresenter
  #     delegate :title, :subtitle, :creator, to: :solr_document
  #   end
  #
  class BasePresenter < ::Hyrax::WorkShowPresenter
    include PresentsAttributes
    include HumanizesDateFields

    # delegate common properties to solr_document, so descendents only need
    # to add their unique fields
    delegate :contributor, :creator, :description, :identifier, :keyword, :language,
             :language_label, :location, :local_identifier, :note, :permalink, :physical_medium,
             :publisher, :related_resource, :resource_type, :rights_holder, :rights_statement,
             :source, :standard_identifier, :subject, :subtitle, :title_alternative, :title, :visibility,
             :registered?,
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

    # Conditions for whether to display only metadata or the files attached:
    #   - "admin" users can see files for all items
    #   - if the user can +:download+ a record (which includes those that can +:read+),
    #     we'll show the file
    #     - if the item is "authenticated" and the user is logged in, show the file
    #     - if the item is "public" and not embargoed, show the file
    #
    # Otherwise, we'll display just the metadata.
    #
    # @return [true, false]
    def metadata_only?
      @metadata_only ||= !(current_ability.admin? || current_ability.can?(:download, id))
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

    def subject
      solr_document.subject.zip(solr_document.subject_label)
    end

    # @return [Array<Array<String>>]
    def rights_statement_merged
      solr_document.rights_statement.zip(solr_document.rights_statement_label)
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
