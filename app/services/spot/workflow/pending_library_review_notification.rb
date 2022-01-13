# frozen_string_literal: true
module Spot
  module Workflow
    class PendingLibraryReviewNotification < ::Hyrax::Workflow::AbstractNotification
      private

      def subject
        'Deposit needs review'
      end

      def message
        msg = [
          "#{title} (#{link_to work_id, document_path}) was deposited by #{user.user_key}.",
          "It's been approved by its advisor and is awaiting approval."
        ]

        msg << "\n\n<blockquote>#{comment}</blockquote>" if comment
        msg.join(' ')
      end
    end
  end
end
