# frozen_string_literal: true
#
# Mixin to modify Hyrax's BatchEditForm fields to add our own common metadata fields
# to the form. Originally written as a class_eval in spot_overrides, this Module is now
# intended to be included in the spot_overrides file like:
#
# @example
#   Rails.application.reloader.to_prepare do
#     # ...
#     Hyrax::Forms::BatchEditForm.include(Spot::Forms::BatchEditFormTermsAndPermittedParams)
#   end
#
# @note This is used for the pre-Valkyrization forms and can be removed once we're fully Valkyrized.
# @see config/initializers/spot_overrides.rb
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
