module Spot
  class BasePresenter < Hyrax::WorkShowPresenter
    def abstract
      value_for 'abstract_tesim'
    end

    def academic_department
      value_for 'academic_department_ssim'
    end

    def bibliographic_citation
      value_for 'bibliographic_citation_tesim'
    end

    def contributor
      value_for 'contributor_tesim'
    end

    def creator
      value_for 'creator_tesim'
    end

    def date_available
      value_for 'date_available_ssim'
    end

    def date_issued
      value_for 'date_issued_ssim'
    end

    def date_modified
      value_for 'date_modified_dtsi'
    end

    def date_uploaded
      value_for 'date_uploaded_dtsi'
    end

    def depositor
      value_for 'depositor_tesim'
    end

    def description
      value_for 'description_tesim'
    end

    def division
      value_for 'division_ssim'
    end

    def editor
      value_for 'editor_tesim'
    end

    def identifier
      value_for 'identifier_ssim'
    end

    def keyword
      value_for 'keyword_ssim'
    end

    def language_display
      value_for 'language_display_ssim'
    end

    def license
      value_for 'license_ssim'
    end

    def organization
      value_for 'organization_ssim'
    end

    def resource_type
      value_for 'resource_type_ssim'
    end

    def source
      value_for 'source_tesim'
    end

    def subject
      value_for 'subject_ssim'
    end

    def subtitle
      value_for 'subtitle_tesim'
    end

    def title_alternative
      value_for 'title_alternative_tesim'
    end

    protected

    def value_for(key)
      solr_document[key] || []
    end
  end
end
