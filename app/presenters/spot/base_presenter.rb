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
             :language_label, :location, :note, :permalink, :physical_medium,
             :publisher, :registered?, :related_resource, :resource_type, :rights_holder, :rights_statement,
             :source, :subject, :subtitle, :title_alternative, :title,
             :visibility, :citation_journal_title, :citation_volume, :citation_issue,
             :citation_firstpage, :citation_lastpage,
             to: :solr_document

    delegate :public?, to: :solr_document

    # Copying this locally to force download URLs to be https.
    # This method doesn't appear to change through Hyrax 4.0.
    #
    # @return [String]
    # @see https://github.com/samvera/hyrax/blob/hyrax-v4.0.0.rc2/app/presenters/hyrax/work_show_presenter.rb#L58-L62
    def download_url
      return '' if representative_presenter.nil?
      Hyrax::Engine.routes.url_helpers.download_url(representative_presenter, host: request.host, protocol: 'https://')
    end

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

    # Check if an item's record should include files or just display the metadata.
    #
    # @return [true, false]
    def metadata_only?
      @metadata_only ||= metadata_only_flag
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

    private

    def metadata_only_flag
      # exit early if the work is public or the user is an admin
      return false if public? || current_ability.admin?

      # check if the user can read the solr_document (checks read_users and _groups)
      return false if current_ability.can?(:read, solr_document)

      # otherwise, only display the metadata
      true
    end

    def replace_line_breaks(text)
      text.gsub(/\r?\n/, '<br>').html_safe
    end
  end
end
