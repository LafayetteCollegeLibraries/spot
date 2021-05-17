# frozen_string_literal: true
module Spot
  module RedirectionHelpers
    def redirect_params_for(solr_document:)
      controller = solr_document['has_model_ssim'].first.downcase.pluralize
      params = { controller: "hyrax/#{controller}", action: 'show', id: solr_document['id'] }

      return Hyrax::Engine.routes.url_for(**params, only_path: true) if controller == 'collections'

      params
    end
  end
end
