# frozen_string_literal: true
#
# The Hyrax::CollectionPresenter with support for FeaturedCollections
module Spot
  class CollectionPresenter < Hyrax::CollectionPresenter
    # @return [true,false]
    def collection_featurable?
      user_can_feature_collections? && solr_document.public?
    end

    # @return [true,false]
    def display_feature_link?
      collection_featurable? && FeaturedCollection.can_create_another? && !featured?
    end

    # @return [true,false]
    def display_unfeature_link?
      collection_featurable? && featured?
    end

    # @return [true,false]
    def featured?
      @featured = FeaturedCollection.where(collection_id: solr_document.id).exists? if @featured.nil?
      @featured
    end

    # @return [true,false]
    def user_can_feature_collections?
      current_ability.can?(:manage, FeaturedCollection)
    end
  end
end
