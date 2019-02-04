# frozen_string_literal: true
#
# This is kind of a hodge-podge at the moment, but will/should represent
# the common shared solr fields across models.
module Spot
  class BasePresenter < Hyrax::WorkShowPresenter
    include ActionView::Helpers::UrlHelper

    # Is the document's visibility public?
    #
    # @return [true, false]
    def public?
      solr_document.visibility == ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    # Our document's identifiers mapped to Spot::Identifier objects
    #
    # @return [Array<Spot::Identifier>]
    def mapped_identifiers
      identifier.map { |str| Spot::Identifier.from_string(str) }
    end

    # @return [Array<String>]
    def abstract
      value_for 'abstract_tesim'
    end

    # @return [Array<String>]
    def academic_department
      value_for 'academic_department_tesim'
    end

    # @return [Array<String>]
    def bibliographic_citation
      value_for 'bibliographic_citation_tesim'
    end

    # @return [Array<String>]
    def contributor
      value_for 'contributor_tesim'
    end

    # @return [Array<String>]
    def creator
      value_for 'creator_tesim'
    end

    # @return [Array<String>]
    def date_available
      value_for 'date_available_ssim'
    end

    # @return [Array<String>]
    def date_issued
      value_for 'date_issued_ssim'
    end

    # @return [Array<String>]
    def date_modified
      value_for 'date_modified_dtsi'
    end

    # @return [Array<String>]
    def date_uploaded
      value_for 'date_uploaded_dtsi'
    end

    # @return [Array<String>]
    def depositor
      value_for 'depositor_tesim'
    end

    # @return [Array<String>]
    def description
      value_for 'description_tesim'
    end

    # @return [Array<String>]
    def division
      value_for 'division_tesim'
    end

    # @return [Array<String>]
    def editor
      value_for 'editor_tesim'
    end

    # @return [Array<String>]
    def identifier
      value_for 'identifier_ssim'
    end

    # @return [Array<String>]
    def keyword
      value_for 'keyword_tesim'
    end

    # @return [Array<String>]
    def language_label
      value_for 'language_label_ssim'
    end

    # @return [Array<String>]
    def license
      value_for 'license_ssim'
    end

    # @return [Array<String>]
    def organization
      value_for 'organization_tesim'
    end

    # @return [Array<String>]
    def physical_medium
      value_for 'physical_medium_tesim'
    end

    # @return [Array<String>]
    def place
      value_for 'place_ssim'
    end

    # place values + labels zipped into tuples.
    #
    # @example
    #   presenter.place_merged
    #   => [['http://sws.geonames.org/5188140/', 'Easton, PA']]
    #
    # @return [Array<Array<String>>]
    def place_merged
      place.zip(value_for('place_label_ssim'))
    end

    # @return [Array<String>]
    def resource_type
      value_for 'resource_type_tesim'
    end

    # @return [Array<String>]
    def rights_statement
      value_for('rights_statement_ssim')
    end

    # @return [Array<Array<String>>]
    def rights_statement_merged
      rights_statement.zip(value_for('rights_statement_label_ssim'))
    end

    # @return [Array<String>]
    def source
      value_for 'source_tesim'
    end

    # @return [Array<String>]
    def subject
      value_for 'subject_tesim'
    end

    # @return [Array<String>]
    def subtitle
      value_for 'subtitle_tesim'
    end

    # @return [Array<String>]
    def title_alternative
      value_for 'title_alternative_tesim'
    end

    protected

      # Helper method to fetch the solr value for an field
      # or return an empty array
      #
      # @param [String] key
      # @return [Array<String>]
      def value_for(key)
        solr_document[key] || []
      end
  end
end
