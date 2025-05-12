# frozen_string_literal: true

# instead of copying Hyrax::Forms::BatchEditForm locally, which is causing conflicts
# with loading Hyrax::Forms::ResourceForm (method form), use class_eval to apply those
# patches, which will be unnecessary once we're valkyrized.
module Spot
  module Forms
    module BatchEditFormTermsAndPermittedParams
      extend ActiveSupport::Concern

      included do
        self.terms = [
          :creator, :contributor, :description, :note,
          :keyword, :resource_type, :license, :publisher,
          :subject, :language, :identifier, :location,
          :related_resource
        ]

        def self.build_permitted_params
          original_params = super
          skip_keys = [:based_near, :based_near_attributes, :date_created]

          original_params.reject { |config| skip_keys.any? { |k| config.is_a?(Hash) ? config.key?(k) : config == k } }
                         .union([{ note: [] }, { location: [] }, { location_attributes: [:id, :_destroy] }])
        end
      end
    end
  end
end
