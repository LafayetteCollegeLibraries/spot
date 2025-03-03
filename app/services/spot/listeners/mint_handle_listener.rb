# frozen_string_literal: true
module Spot
  module Listeners
    # Enqueue MintHandleJob after a work is deposited.
    class MintHandleListener
      def on_object_deposited(object:, user:) # rubocop:disable Lint/UnusedMethodArgument
        MintHandleJob.perform_later(object.id.to_s)
      end
    end
  end
end
