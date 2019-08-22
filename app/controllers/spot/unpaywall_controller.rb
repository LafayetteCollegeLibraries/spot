# frozen_string_literal: true
module Spot
  class UnpaywallController < ::ApplicationController
    # Searches the Unpaywall API for a DOI and returns the results as JSON
    #
    # @see Spot::UnpaywallSearchService
    def search
      search_results = search_service.find(params[:doi])
      render json: search_results
    rescue search_service::DOINotFound, search_service::NoOSOption => e
      render json: { error: true, message: e.message }, status: 404
    rescue search_service::SearchError => e
      render json: { error: true, message: e.message }, status: 500
    end

    private

      # @return [Class]
      def search_service
        UnpaywallSearchService
      end
  end
end
