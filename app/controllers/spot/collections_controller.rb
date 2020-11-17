# frozen_string_literal: true
module Spot
  class CollectionsController < Hyrax::CollectionsController
    def index
      @response = collection_index_response
      @collections = collection_presenters

      render 'index', layout: 'hyrax/1_column'
    end

    private

      # @note: this will change once we upgrade to hyrax@3
      def collection_index_response
        blacklight_config.repository_class.new(blacklight_config).search(index_search_builder)
      end

      def collection_presenters
        @response.documents.map { |doc| presenter_class.new(doc, current_ability, request) }
      end

      def index_search_builder
        Spot::CollectionsIndexSearchBuilder.new(self).with(page: params[:page], rows: params[:per_page])
      end
  end
end
