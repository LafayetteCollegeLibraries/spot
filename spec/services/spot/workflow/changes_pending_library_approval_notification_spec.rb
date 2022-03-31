# frozen_string_literal: true
RSpec.describe Spot::Workflow::ChangesPendingLibraryReviewNotification do
  it_behaves_like 'a Spot::Workflow notification' do
    let(:subject_line) { 'Submission requires review' }
    let(:message) do
      "Changes for <em><a href=\"/concern/student_works/#{workflow_object.id}\">#{workflow_object.title.first}</a></em> " \
        "have been submitted by #{workflow_action_user.display_name} and require your review." \
        "<blockquote>#{workflow_comment_html}</blockquote>"
    end
  end
end
