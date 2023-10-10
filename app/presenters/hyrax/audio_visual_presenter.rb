# frozen_string_literal: true
module Hyrax
  class AudioVisualPresenter < ::Spot::BasePresenter
    delegate :title, :date, :embed_url, to: :solr_document
  end
end
