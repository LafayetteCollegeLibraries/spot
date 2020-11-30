# frozen_string_literal: true
module Spot
  class CollectionsIndexSearchBuilder < Hyrax::CollectionSearchBuilder
    self.default_processor_chain += [:only_include_top_level_collections]

    def sort_field
      'title_sort_si'
    end

    private

      def only_include_top_level_collections(solr_params)
        solr_params[:fq] ||= []
        solr_params[:fq] << '-member_of_collection_ids_ssim:[* TO *]'
      end
  end
end
