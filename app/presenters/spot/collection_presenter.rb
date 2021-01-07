# frozen_string_literal: true
#
# The Hyrax::CollectionPresenter with support for FeaturedCollections
module Spot
  class CollectionPresenter < Hyrax::CollectionPresenter
    include ActionView::Helpers::AssetUrlHelper
    include PresentsAttributes

    delegate :abstract, :permalink, to: :solr_document

    # Presenter fields displayed on the #show sidebar (on the right).
    # Modify this to change what's displayed + the order.
    #
    # @return [Array<Symbol>]
    def self.terms
      [
        :total_items,
        :location,
        :sponsor,
        :modified_date,
        :permalink
      ]
    end

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
      FeaturedCollection.where(collection_id: solr_document.to_param).exists?
    end

    # Is the document's visibility public?
    #
    # @return [true, false]
    def public?
      solr_document.visibility == ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    # SolrDocument#related_resource maps to +related_resource_tesim+, since Publication and Image both
    # index the field as +:stored_searchable, :facetable+. We store links in Collection#related_resource
    # and index them as +:symbol+ (aka '*_ssim'), so we need to point there instead.
    #
    # @return [Array<String>]
    def related_resource
      solr_document['related_resource_ssim']
    end

    # @return [true,false]
    def user_can_feature_collections?
      current_ability.can?(:manage, FeaturedCollection)
    end
  end
end
