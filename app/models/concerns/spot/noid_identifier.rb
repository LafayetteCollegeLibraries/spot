# frozen_string_literal: true
module Spot
  # Mixin to ensure that a work's identifiers include "noid:#{work.id}"
  module NoidIdentifier
    extend ActiveSupport::Concern

    included do
      before_save :ensure_noid_in_identifier
    end

    private

      # @return [void]
      def ensure_noid_in_identifier
        return if id.nil?

        noid_id = "noid:#{id}"
        return if identifier.include?(noid_id)

        self.identifier += [noid_id]
      end
  end
end
