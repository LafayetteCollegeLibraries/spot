# frozen_string_literal: true
#
# Helpers to split out facets useful to admins from the regular ("general") ones
module Spot
  module FacetHelper
    # render partials for the majority of our partials
    #
    # @return [String]
    def render_general_facet_partials
      render_facet_partials(general_facet_names)
    end

    # render only the admin facet partials
    #
    # @return [String]
    def render_admin_facet_partials
      render_facet_partials(admin_facet_names)
    end

    # Returns only the facets where the option +:admin+ is truthy
    #
    # @return [Array<String>]
    def admin_facet_names
      @admin_facet_names ||=
        blacklight_config.facet_fields.select { |_facet, opts| opts[:admin] }.values.map(&:field)
    end

    # Facet names whose configuration does not include a truthy +:admin+ value.
    #
    # @return [Array<String>]
    def general_facet_names
      facet_field_names - admin_facet_names
    end
  end
end
