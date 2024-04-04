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

  # The search param used by PDFjs to prepopulate the search bar
  #
  # @return [String]
  def query_param
    return unless search_query || params[:page]&.to_i
    base = ""
    base += "page=#{params[:page]}&" if params[:page]
    base +="search=#{search_query}&phrase=true"
  end

  private

  # @return [String]
  def search_query
    search&.query_params && search.query_params[:q]
  end

  def search
    current_search_session
  end
end
