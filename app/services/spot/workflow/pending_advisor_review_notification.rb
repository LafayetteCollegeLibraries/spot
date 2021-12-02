# frozen_string_literal: true
module Spot
  module Workflow
    class PendingAdvisorReviewNotification < ::Hyrax::Workflow::AbstractNotification
      private

        def advisor_user
          @advisor_user ||= User.find_by(lnumber: document.advisor.first)
        end

        def subject
          'Deposit needs review'
        end

        def message
          "#{title} (#{link_to work_id, document_path}) was deposited by #{user.user_key} and is awaiting approval #{comment}"
        end

        def users_to_notify
          super << advisor_user
        end
    end
  end
end
