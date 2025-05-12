# frozen_string_literal: true
#
# @see Spot::UpdatedCollectionsDashboardControllerFacetsBehavior
module Spot
  module UpdatedWorksDashboardControllerFacetsBehavior
    extend ::ActiveSupport::Concern

    module ClassMethods
      def update_facet_labels!
        blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
      end
    end

    included { self.class.update_facet_labels! }
  end
end
