module Hyrax
  class PublicationPresenter < Spot::BasePresenter
    def identifier_types
      %w(hdl doi issn isbn)
    end

    def identifier_hdl
      value_for 'identifier_hdl_ssim'
    end

    def identifier_doi
      value_for 'identifier_doi_ssim'
    end

    def identifier_issn
      value_for 'identifier_issn_ssim'
    end

    def identifier_isbn
      value_for 'identifier_isbn_ssim'
    end
  end
end
