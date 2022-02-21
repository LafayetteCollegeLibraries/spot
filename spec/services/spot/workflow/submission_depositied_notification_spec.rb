# frozen_string_literal: true
RSpec.describe Spot::Workflow::SubmissionDepositedNotification do
  it_behaves_like 'a Spot::Workflow notification' do
    let(:subject_line) { 'Submission approved' }
    let(:message) do
      "Your submission, <em><a href=\"/concern/student_works/#{workflow_object.id}\">#{workflow_object.title.first}</a></em>, " \
        "has been approved. Thank you!"
    end
  end
end
