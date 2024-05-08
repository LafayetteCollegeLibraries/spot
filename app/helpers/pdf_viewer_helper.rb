# frozen_string_literal: true
#
# Helper methods to generate the PDFjs viewer and populate the search query
# (if present)
module PdfViewerHelper
  # @param [String] path
  # @return [String] URL to the viewer
  def viewer_url(path)
    "/pdf/web/viewer.html?file=#{path}##{query_param}"
  end

  # The search/page params used by PDFjs to prepopulate the search bar
  #
  # @return [String]
  def query_param
    return unless search_query || page_param
    qp = {}
    qp[:page] = page_param if page_param

    if search_query
      qp[:search] = search_query
      qp[:phrase] = true
    end

    URI.encode_www_form(qp)
  end

  def page_param
    search&.query_params&.try(:[], :page)
  end

  # @return [String]
  def search_query
    search&.query_params&.try(:[], :q)
  end

  def search
    current_search_session
  end
end
