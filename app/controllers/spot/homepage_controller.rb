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
      _, docs = search_service.search_results
      docs
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    def featured_collections
      FeaturedCollection.all.map do |c|
        collection_presenter_class.new(SolrDocument.new(c.collection_id), current_ability, request)
      end
    end

    def collection_presenter_class
      Hyrax::CollectionsController.presenter_class
    end
  end
end
