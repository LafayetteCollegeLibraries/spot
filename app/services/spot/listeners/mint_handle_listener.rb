# frozen_string_literal: true
module Spot
  module Listeners
    # Enqueue MintHandleJob after a work is deposited.
    class MintHandleListener
      # @param [Dry::Events::Event] event
      def on_object_deposited(event)
        ::MintHandleJob.perform_later(event[:object].try(:id).try(:to_s))
      end
    end
  end
end
