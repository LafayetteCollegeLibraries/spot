# frozen_string_literal: true
RSpec.describe Spot::Workflow::ChangesPendingAdvisorReviewNotification do
  # needed for indexing the advisor's name
  include_context 'mock WDS service'

  it_behaves_like 'a Spot::Workflow notification' do
    let(:subject_line) { 'Deposit needs review' }
    let(:message) do
      "#{workflow_action_user.display_name} has made changes to <em><a href=\"/concern/student_works/#{workflow_object.id}\">#{workflow_object.title.first}</a></em>." \
      "<blockquote>#{workflow_comment_html}</blockquote>" \
      "Please review and approve or request further edits."
    end
    let(:workflow_object) { create(:student_work, user: depositing_user, advisor: [advisor_user.email]) }
    let(:advisor_user) { create(:user) }
    let(:recipients) { [advisor_user] }
  end
end
