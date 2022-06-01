# frozen_string_literal: true
module Spot
  # Helper methods for common redirection tasks.
  module RedirectionHelpers
    # Solves a problem where passing a params hash including +{ controller: 'hyrax/collections', action: 'show' }+ would
    # result in a No Route Matches error. Passing these params to +Hyrax::Engine.routes.url_for+ will work for
    # collections but not other work types. There's probably something I'm missing, but this will at least
    # allow us to resolve Handles and legacy URLs for collections.
    def redirect_params_for(solr_document:)
      controller = solr_document['has_model_ssim'].first.underscore.pluralize
      params = { controller: "hyrax/#{controller}", action: 'show', id: solr_document['id'] }

      return Hyrax::Engine.routes.url_for(**params, only_path: true) if controller == 'collections'

      params
    end
  end
end
