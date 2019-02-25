# frozen_string_literal: true
module Spot
  module Forms
    class CollectionForm < Hyrax::Forms::CollectionForm
      self.terms = [
        :title,
        :short_description,
        :description,
        :visibility,
        :collection_type_gid
      ]

      def self.model_attributes(form_params)
        super.tap do |params|
          params['title'] = Array(params['title']) if params['title']
        end
      end

      def primary_terms
        terms - [:visibility, :collection_type_gid]
      end

      def secondary_terms
        []
      end

      # Limiting to one title via the form
      #
      # @return [String]
      def title
        self['title'].first
      end
    end
  end
end
