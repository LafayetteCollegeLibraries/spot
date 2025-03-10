# frozen_string_literal: true
module Spot
  class WorkFormService < Hyrax::WorkFormService
    def self.form_class(curation_concern)
      super
    rescue NameError
      # need to touch this to ensure that the class is loaded before we inherit from it
      'Hyrax::Forms::ResourceForm'.constantize

      Object.const_get("#{curation_concern.model_name.name}Form")
    end
  end
end
