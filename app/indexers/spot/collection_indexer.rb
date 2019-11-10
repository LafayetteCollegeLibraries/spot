# frozen_string_literal: true
module Spot
  class CollectionIndexer < Hyrax::CollectionIndexer
    include IndexesLanguageAndLabel

    self.thumbnail_path_service = ::Spot::CollectionThumbnailPathService

    def generate_solr_document
      super.tap do |doc|
        doc['title_sort_si'] = object.title.first.to_s.downcase

        if (slug_id = object.identifier.find { |id| id.start_with? 'slug:' })
          doc['collection_slug_ssi'] = Spot::Identifier.from_string(slug_id).value
        end
      end
    end
  end
end
