# frozen_string_literal: true
module Spot
  # Custom ItemComponent for Visibility facets. We want to display the PermissionBadge
  # for each possibility as opposed to the plain-text value. This was previously accomplished
  # using a helper method, but wrapping a span badge inside a hyperlink in Bootstrap 4
  # cuts off the text with a negative indentation. So instead we'll render an unwrapped link.
  #
  # @see app/presenters/spot/permission_badge.rb
  class VisibilityFacetItemComponent < Blacklight::FacetItemComponent
    def render_facet_value
      link_to_unless(@suppress_link,
                     permission_badge.visibility_label,
                     href,
                     class: "facet-select badge #{permission_badge.badge_class} px-2 py-1",
                     rel: 'nofollow') + render_facet_count
    end

    private

    def permission_badge
      Spot::PermissionBadge.new(label)
    end
  end
end
