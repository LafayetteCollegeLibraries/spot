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

    # @return [Array<Hash<String => *>>]
    def manifest_metadata
      return super unless respond_to?(:manifest_metadata_fields)

      manifest_metadata_fields.inject([]) do |metadata, field|
        values = iiif_metadata_for(field)
        next metadata if values.nil?

        metadata << values
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

    private

      # Maps a field + its values to a Hash of 'label' and 'value',
      # where 'label' is our translated field name and 'value' is
      # an Array of values.
      #
      # @return [Hash<String => String,Array<String>>
      # @todo for LD fields, can we include both the URI and the label?
      def iiif_metadata_for(field)
        raw_values = send(field.to_sym)
        return if raw_values.blank?

        # our controlled fields are typically zipped a [uri, label]
        # tuple. for now, we'll only use the label of the value,
        # but this is where we would map to a Hash of URI and label
        # in the future
        wrapped_values = Array.wrap(values).map { |v| v.is_a?(Array) ? v.last : v }

        { 'label' => I18n.t("blacklight.search.fields.#{field}", field.to_s.humanize.titleize),
          'value' => wrapped_values }
      end
  end
end
