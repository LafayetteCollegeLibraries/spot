# frozen_string_literal: true
module Spot
  module Workflow
    # Notification sent out to a work's advisor after its initial submission
    # (differs from ChangesPendingAdvisorReview, which is intended for a
    # work-in-process context)
    class SubmittedPendingAdvisorReviewNotification < AbstractNotification
      self.mailer_method = :submitted_pending_advisor_review
    end
  end
end
