# frozen_string_literal: true
module Spot
  class CollectionIndexer < Hyrax::CollectionIndexer
    include IndexesLanguageAndLabel

    self.thumbnail_path_service = ::Spot::CollectionThumbnailPathService
  end
end
