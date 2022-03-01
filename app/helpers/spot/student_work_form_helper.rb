# frozen_string_literal: true
module Spot
  module StudentWorkFormHelper
    # Limit tabs on StudentWorkForm to just metadata and files unless the user is an admin
    def form_tabs_for(form:)
      return super unless form.is_a?(Hyrax::StudentWorkForm)
      return super if current_user.admin?

      %w[metadata files]
    end
  end
end
