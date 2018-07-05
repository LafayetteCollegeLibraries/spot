module Hyrax
  class PublicationPresenter < Hyrax::WorkShowPresenter
    def bibliographic_citation
      solr_document['bibliographic_citation_tesim'] || []
    end

    def identifier
      solr_document['identifier_ssim'] || []
    end

    def language_display
      solr_document['language_display_ssim'] || []
    end

    def creator
      solr_document['creator_ssim'] || []
    end
  end
end
