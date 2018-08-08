module Spot
  class BasePresenter < Hyrax::WorkShowPresenter
    def abstract
      value_for 'abstract_tesim'
    end

    def bibliographic_citation
      value_for 'bibliographic_citation_tesim'
    end

    def creator
      value_for 'creator_ssim'
    end

    def description
      value_for 'description_tesim'
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

    def subtitle
      value_for 'subtitle_tesim'
    end

    protected

    def value_for(key)
      solr_document[key] || []
    end
  end
end
