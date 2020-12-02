# frozen_string_literal: true
module Spot
  class CollectionsController < Hyrax::CollectionsController
    def index
      @response = collection_index_response
      @collections = @response.documents.map { |doc| presenter_class.new(doc, current_ability, request) }

      render 'index', layout: 'hyrax/1_column'
    end

    private

      # @note: this will change once we upgrade to hyrax@3
      def collection_index_response
        blacklight_config.repository_class.new(blacklight_config).search(index_search_builder)
      end

      def index_search_builder
        Spot::ParentCollectionsSearchBuilder.new(self).with(page: params[:page], rows: params[:per_page])
      end
  end
end
