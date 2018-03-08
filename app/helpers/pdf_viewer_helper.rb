module PdfViewerHelper
  def viewer_url(path)
    "/web/viewer.html?file=#{path}##{query_param}"
  end

  def query_param
    return unless search_query
    "search=#{search_query}&phrase=true"
  end

  private

  def search_query
    search && search.respond_to?(:query_params) && search.query_params[:q]
  end

  def search
    current_search_session
  end
end
