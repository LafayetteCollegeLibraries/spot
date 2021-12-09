# frozen_string_literal: true
#
# Following along with +Hyrax::HomepageController+, but leaving out
# the bits we're not using.
module Spot
  class HomepageController < ApplicationController
    # adding Blacklight behavior (so that we can search the catalog easily)
    include Blacklight::SearchContext
    include Blacklight::SearchHelper
    include Blacklight::AccessControls::Catalog

    helper Hyrax::ContentBlockHelper

    def index
      @presenter = presenter_class.new(recent_works, featured_collections)
    end

  private

    # @return [Array<SolrDocument>]
    def recent_works
      _, docs = search_results(q: recent_items_query, sort: 'date_uploaded_dtsi desc', rows: 6)
      docs
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    def featured_collections
      FeaturedCollection.all.map do |c|
        collection_presenter_class.new(SolrDocument.new(Collection.find(c.collection_id).to_solr),
                                       current_ability,
                                       request)
      end
    end

    def collection_presenter_class
      Hyrax::CollectionsController.presenter_class
    end

    # @return [Class]
    def presenter_class
      Spot::HomepagePresenter
    end

    def recent_items_query
      "{!terms f=has_model_ssim}#{Hyrax.config.curation_concerns.join(',')}"
    end
  end
end
