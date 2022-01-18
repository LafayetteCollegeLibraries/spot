# frozen_string_literal: true
module Spot
  module Workflow
    class PendingAdvisorReviewNotification < ::Hyrax::Workflow::AbstractNotification
      private

      def subject
        'Deposit needs review'
      end

      def message
        msg = "#{title} (#{link_to work_id, document_path}) was submitted by #{document.depositor} and is awaiting approval."
        msg += "\n\n<blockquote>#{comment}</blockquote>" unless comment.empty?
        msg
      end

      def users_to_notify
        super << advisor_user
      end

      def advisor_user
        advisor_key = document.advisor.first

        case advisor_key
        when /^L\d{8}$/
          User.find_by(lnumber: advisor_key)
        when /^[^@]+@\w+\.\w+$/
          User.find_by(email: advisor_key)
        end
      end
    end
  end
end
