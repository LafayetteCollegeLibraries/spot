# frozen_string_literal: true
module Spot
  class PermissionBadge < Hyrax::PermissionBadge
    VISIBILITY_LABEL_CLASS = {
      authenticated: "badge-info",
      embargo: "badge-warning",
      lease: "badge-warning",
      metadata: "badge-info",
      open: "badge-success",
      restricted: "badge-danger"
    }.freeze
  end
end
