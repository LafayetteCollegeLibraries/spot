# frozen_string_literal: true
#
# the dashboard/my/collections (+ thus, dashboard/collections) controller defines
# blacklight facets + uses I18n.t to provide a label. as we've found from past experience,
# this can get called _before_ all of the locales are loaded, resulting in a
# "translation missing" message being provided as a fall-back label. this should
# prevent that error from appearing by replacing the +translate+ calls with a symbolized
# I18n key (see also 0717dee, + catalog_controller.rb)
module Spot
  module UpdatedCollectionsDashboardControllerFacetsBehavior
    extend ::ActiveSupport::Concern

    module ClassMethods
      def update_facet_labels!
        blacklight_config.facet_fields['visibility_ssi'].label = :'hyrax.dashboard.my.heading.visibility'
        blacklight_config.facet_fields[Hyrax.config.collection_type_index_field].label = :'hyrax.dashboard.my.heading.collection_type'
        blacklight_config.facet_fields['has_model_ssim'].label = :'hyrax.dashboard.my.heading.collection_type'
      end
    end

    included { self.class.update_facet_labels! }
  end
end