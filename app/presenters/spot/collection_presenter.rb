# frozen_string_literal: true
#
# The Hyrax::CollectionPresenter with support for FeaturedCollections
module Spot
  class CollectionPresenter < Hyrax::CollectionPresenter
    include ActionView::Helpers::AssetUrlHelper

    delegate :abstract, :related_resource, to: :solr_document

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

    # @todo this is a no-op at the moment. we'll need to update the metadata to provide
    #       a URL that provides more information about the collection
    def learn_more_url; end

    # @return [true,false]
    def user_can_feature_collections?
      current_ability.can?(:manage, FeaturedCollection)
    end
  end
end
