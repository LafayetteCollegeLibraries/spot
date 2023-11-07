# frozen_string_literal: true
module Spot
  class HomepageController < Hyrax::HomepageController
    self.presenter_class = Spot::HomepagePresenter

    with_themed_layout '1_column'

    def index
      @presenter = presenter_class.new(recent_works, featured_collections)
    end

    private

    # Removes the restriction that works displayed on the Homepage require the
    # user to have edit access (?) to them
    #
    # @return [Array<SolrDocument>]
    def recent_works
      (_, docs) = search_service.search_results do |builder|
        builder.rows(6)
        builder.merge(sort: 'date_uploaded_dtsi desc')
      end

      docs
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    def featured_collections
      FeaturedCollection.all.pluck(:collection_id).map do |c|
        collection_presenter_class.new(SolrDocument.find(Collection.find(c.collection_id).id), current_ability, request)
      end
    end

    def collection_presenter_class
      Hyrax::CollectionsController.presenter_class
    end
  end
end
