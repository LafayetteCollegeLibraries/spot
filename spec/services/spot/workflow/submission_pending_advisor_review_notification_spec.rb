# frozen_string_literal: true
RSpec.describe Spot::Workflow::SubmissionPendingAdvisorReviewNotification do
  # needed for indexing the advisor's name
  include_context 'mock WDS service'

  it_behaves_like 'a Spot::Workflow notification' do
    let(:subject_line) { 'Submission requires review' }
    let(:message) do
      "A work by #{depositing_user.display_name} (<em><a href=\"/concern/student_works/#{workflow_object.id}\">#{workflow_object.title.first}</a></em>) "\
        "was submitted and is awaiting your approval. <blockquote>#{workflow_comment_html}</blockquote>" \
        "Please approve or request changes using the form on the work's page."
    end
    let(:advisor_user) { create(:user) }
    let(:workflow_object) { create(:student_work, user: depositing_user, advisor: [advisor_user.email]) }
    let(:recipients) { [advisor_user] }
  end
end
