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
    include ::Spot::PresentsAttributes

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

    def manifest_metadata
      return super unless respond_to?(:manifest_metadata_fields)

      manifest_metadata_fields.inject([]) do |metadata, field|
        values = send(field)
        next metadata if values.blank?

        # our presenter logic for controlled fields is to return an array
        # for each value in the form of: [uri, label]. while mapping through
        # the values for each field, if we get to a value that is an array,
        # we'll assume it's controlled and provide a Hash with '@id' pointing
        # to the uri. otherwise, retain the value as-is.
        metadata << {
          'label' => I18n.t("blacklight.search.fields.#{field}", field.to_s.humanize.titleize),
          'value' => Array.wrap(values).map { |v| v.is_a?(Array) ? { '@id' => v.first } : v }
        }
      end
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
