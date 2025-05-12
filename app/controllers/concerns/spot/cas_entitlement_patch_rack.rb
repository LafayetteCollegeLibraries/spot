# frozen_string_literal: true
module Spot
  # Only store entitlements related to us in the session to prevent a cookie overflow.
  module CasEntitlementPatchRack
    extend ActiveSupport::Concern

    # :nocov:
    def store_session(request, user, ticket, extra_attrs = {})
      extra_attrs.select! { |key, _val| RackCAS.config.extra_attributes_filter.map(&:to_s).include?(key.to_s) } if RackCAS.config.extra_attributes_filter?

      if extra_attrs['eduPersonEntitlement'].present?
        extra_attrs['eduPersonEntitlement'] = Array.wrap(extra_attrs['eduPersonEntitlement']).select do |val|
          URI.parse(val).host == Spot::CasUserRolesService.entitlement_host
        end
      end

      request.session['cas'] = { 'user' => user, 'ticket' => ticket, 'extra_attributes' => extra_attrs }
    end
  end
end
