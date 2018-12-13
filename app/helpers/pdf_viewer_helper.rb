# frozen_string_literal: true
#
# Helper methods to generate the PDFjs viewer and populate the search query
# (if present)
module PdfViewerHelper
  # @param [String] path
  # @return [String] URL to the viewer
  def viewer_url(path)
    "/web/viewer.html?file=#{path}##{query_param}"
  end

  # The search param used by PDFjs to prepopulate the search bar
  #
  # @return [String]
  def query_param
    return unless search_query
    "search=#{search_query}&phrase=true"
  end

  private

    # @return [String]
    def search_query
      search && search.respond_to?(:query_params) && search.query_params[:q]
    end

    def search
      current_search_session
    end
end
