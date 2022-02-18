# frozen_string_literal: true
RSpec.describe Spot::Workflow::SubmissionPendingLibraryReviewNotification do
  it_behaves_like 'a Spot::Workflow notification' do
    let(:subject_line) { 'Submission requires review' }
    let(:message) do
      "A work submitted by #{depositing_user.display_name} has been approved by its advisor (#{workflow_action_user.display_name}) " \
        "and requires your review.<blockquote>#{workflow_comment_html}</blockquote>" \
        "View <em><a href=\"/concern/student_works/#{workflow_object.id}\">#{workflow_object.title.first}</a></em> " \
        "to approve or request changes."
    end
  end
end
